using UnityEngine;

public class ScannerOriginSender : MonoBehaviour
{
    [Header("Scanner")]
    [SerializeField] private Material scannerMaterial;
    [SerializeField] private Transform scannerOrigin;

    private static readonly int ScannerOriginId = Shader.PropertyToID("_ScannerOrigin");

    private void LateUpdate()
    {
        if (scannerMaterial == null || scannerOrigin == null)
            return;

        scannerMaterial.SetVector(ScannerOriginId, scannerOrigin.position);
    }
}