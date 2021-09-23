using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ripple : MonoBehaviour
{
    public int TextureSize = 512;

    public RenderTexture PrevRT;
    public RenderTexture CurrentRT;
    RenderTexture TmpRT;

    Camera mainCamera;

    [Range(0, 1f)]
    public float DrawRadius = 0.1f;

    public Shader DrawShader;
    Material DrawMat;

    public Shader RippleShader;
    Material RippleMat;


    public void Start()
    {
        mainCamera = Camera.main.GetComponent<Camera>();

        PrevRT = CreateRT();
        CurrentRT = CreateRT();
        TmpRT = CreateRT();

        DrawMat = new Material(DrawShader);
        RippleMat = new Material(RippleShader);

        GetComponent<Renderer>().material.mainTexture = CurrentRT;

    }
    public RenderTexture CreateRT()
    {
        RenderTexture rt = new RenderTexture(TextureSize, TextureSize, 0, RenderTextureFormat.RFloat);
        rt.Create();
        return rt;

    }

    private void DrawAt(float x, float y, float radius)
    {
        DrawMat.SetTexture("_SourceTex", CurrentRT);
        DrawMat.SetVector("_Pos", new Vector4(x, y, radius));

        Graphics.Blit(null, TmpRT, DrawMat);

        RenderTexture rt;
        rt = TmpRT;
        TmpRT = CurrentRT;
        CurrentRT = rt;

    }

    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Debug.Log(Input.mousePosition);
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;
            if (Physics.Raycast(ray, out hit))
            {
                DrawAt(hit.textureCoord.x, hit.textureCoord.y, DrawRadius);
            }
        }

        RippleMat.SetTexture("_PrevRT", PrevRT);
        RippleMat.SetTexture("_CurrentRT", CurrentRT);

        Graphics.Blit(null, TmpRT, RippleMat);

        Graphics.Blit(TmpRT, PrevRT);

        RenderTexture rt = PrevRT;
        PrevRT = CurrentRT;
        CurrentRT = rt;

    }
}
