#if canImport(OpenGL)

import OpenGL.GL
import Cocoa

// TODO: Figure out way to allow for multiple contexts for different GPUs

public class OpenGLContext: SerialDispatch {
    public lazy var framebufferCache:FramebufferCache = {
        return FramebufferCache(context:self)
    }()
    
    var shaderCache:[String:ShaderProgram] = [:]
    public let standardImageVBO:GLuint
    var textureVBOs:[Rotation:GLuint] = [:]
    var standardVAO: GLuint = 0

    public let context:NSOpenGLContext
    
    public lazy var passthroughShader:ShaderProgram = {
        return crashOnShaderCompileFailure("OpenGLContext"){return try self.programForVertexShader(OneInputVertexShader, fragmentShader:PassthroughFragmentShader)}
    }()

    public let serialDispatchQueue:DispatchQueue = DispatchQueue(label: "com.sunsetlakesoftware.GPUImage.processingQueue", attributes: [])
    public let dispatchQueueKey = DispatchSpecificKey<Int>()

    // MARK: -
    // MARK: Initialization and teardown

    init() {
        serialDispatchQueue.setSpecific(key:dispatchQueueKey, value:81)

        let pixelFormatAttributes:[NSOpenGLPixelFormatAttribute] = [
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAOpenGLProfile),
            NSOpenGLPixelFormatAttribute(NSOpenGLProfileVersion3_2Core),

            NSOpenGLPixelFormatAttribute(NSOpenGLPFADoubleBuffer),
            NSOpenGLPixelFormatAttribute(NSOpenGLPFAAccelerated),
            
            0
        ]
        guard let pixelFormat = NSOpenGLPixelFormat(attributes:pixelFormatAttributes) else {
            fatalError("No appropriate pixel format found when creating OpenGL context.")
        }
        // TODO: Take into account the sharegroup
        guard let generatedContext = NSOpenGLContext(format:pixelFormat, share:nil) else {
            fatalError("Unable to create an OpenGL context. The GPUImage framework requires OpenGL support to work.")
        }
        
        self.context = generatedContext
        generatedContext.makeCurrentContext()
        
        print("--- OpenGL Context Info ---")

        var major: GLint = 0
        var minor: GLint = 0
        glGetIntegerv(GLenum(GL_MAJOR_VERSION), &major)
        glGetIntegerv(GLenum(GL_MINOR_VERSION), &minor)
        let glGetError = glGetError()

        if glGetError == GL_NO_ERROR {
            print("Actual Context Version (from glGetIntegerv): \(major).\(minor)")
        } else {
            print("Error getting GL version integers via glGetIntegerv: \(glGetError)")
            print("Actual Context Version: Unknown (glGetIntegerv failed)")
        }

        if let versionStringPtr = glGetString(GLenum(GL_VERSION)) {
            let versionString = String(cString: versionStringPtr)
            print("GL_VERSION String: \(versionString)")
        } else {
            print("Could not get GL_VERSION string.")
        }

        if let glslVersionStringPtr = glGetString(GLenum(GL_SHADING_LANGUAGE_VERSION)) {
            let glslVersionString = String(cString: glslVersionStringPtr)
            print("GLSL Version String: \(glslVersionString)")
        } else {
            print("Could not get GLSL Version string.")
        }
        print("--------------------------")

        // Generate and bind VAO
        glGenVertexArrays(1, &standardVAO)
        glBindVertexArray(standardVAO)

        // Setup VBOs (their state will be captured by the VAO)
        standardImageVBO = generateVBO(for:standardImageVertices)
        generateTextureVBOs()
        
        // Unbind VAO
        glBindVertexArray(0)

        glDisable(GLenum(GL_DEPTH_TEST))
        glEnable(GLenum(GL_TEXTURE_2D))
    }
    
    deinit {
        // TODO: This needs to be done on the GL thread
        if standardVAO != 0 {
            glDeleteVertexArraysAPPLE(1, &standardVAO)
        }
        // Consider cleaning up VBOs and shader cache as well, potentially on the GL thread.
    }
    
    // MARK: -
    // MARK: Rendering
    
    public func makeCurrentContext() {
        self.context.makeCurrentContext()
    }
    
    func presentBufferForDisplay() {
        self.context.flushBuffer()
    }
    
    // MARK: -
    // MARK: Device capabilities

    public func supportsTextureCaches() -> Bool {
        return false
    }
    
    public var maximumTextureSizeForThisDevice:GLint {get { return _maximumTextureSizeForThisDevice } }
    private lazy var _maximumTextureSizeForThisDevice:GLint = {
        return self.openGLDeviceSettingForOption(GL_MAX_TEXTURE_SIZE)
    }()
    
    public var maximumTextureUnitsForThisDevice:GLint {get { return _maximumTextureUnitsForThisDevice } }
    private lazy var _maximumTextureUnitsForThisDevice:GLint = {
        return self.openGLDeviceSettingForOption(GL_MAX_TEXTURE_IMAGE_UNITS)
    }()
    
    public var maximumVaryingVectorsForThisDevice:GLint {get { return _maximumVaryingVectorsForThisDevice } }
    private lazy var _maximumVaryingVectorsForThisDevice:GLint = {
        return self.openGLDeviceSettingForOption(GL_MAX_VARYING_VECTORS)
    }()

    lazy var extensionString:String = {
        return self.runOperationSynchronously{
            self.makeCurrentContext()
            return String(cString:unsafeBitCast(glGetString(GLenum(GL_EXTENSIONS)), to:UnsafePointer<CChar>.self))
        }
    }()
}
#endif
