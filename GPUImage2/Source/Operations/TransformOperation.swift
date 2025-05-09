#if canImport(OpenGL)
import OpenGL.GL3
#endif

#if canImport(OpenGLES)
import OpenGLES
#endif

#if canImport(COpenGLES)
import COpenGLES.gles2
#endif

#if canImport(COpenGL)
import COpenGL
#endif


public class TransformOperation: BasicOperation {
    public var transform:Matrix4x4 = Matrix4x4.identity { didSet { uniformSettings["transformMatrix"] = transform } }
    var normalizedImageVertices:[GLfloat]!
    
    public init() {
        super.init(vertexShader:TransformVertexShader, fragmentShader:PassthroughFragmentShader, numberOfInputs:1)
        
        ({transform = Matrix4x4.identity})()
    }
    
    public override func internalRenderFunction(_ inputFramebuffer:Framebuffer, textureProperties:[InputTextureProperties]) {
        renderQuadWithShader(shader, uniformSettings:uniformSettings, vertices:normalizedImageVertices, inputTextures:textureProperties)
        releaseIncomingFramebuffers()
    }

    override func configureFramebufferSpecificUniforms(_ inputFramebuffer:Framebuffer) {
        let outputRotation = overriddenOutputRotation ?? inputFramebuffer.orientation.rotationNeededForOrientation(.portrait)
        let aspectRatio = inputFramebuffer.aspectRatioForRotation(outputRotation)
        let orthoMatrix = orthographicMatrix(-1.0, right:1.0, bottom:-1.0 * aspectRatio, top:1.0 * aspectRatio, near:-1.0, far:1.0)
        normalizedImageVertices = normalizedImageVerticesForAspectRatio(aspectRatio)
        
        uniformSettings["orthographicMatrix"] = orthoMatrix
    }
}

func normalizedImageVerticesForAspectRatio(_ aspectRatio:Float) -> [GLfloat] {
    return [-1.0, GLfloat(-aspectRatio), 1.0, GLfloat(-aspectRatio), -1.0,  GLfloat(aspectRatio), 1.0,  GLfloat(aspectRatio)]
}
