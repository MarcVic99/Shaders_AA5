using UnityEngine;
using UnityEngine.InputSystem;

public class PostProcessingController : MonoBehaviour
{
    [System.Serializable]
    public class PostProcessEffect
    {
        public string effectName;
        public Material material;
        public string keyword;
        public Key toggleKey = Key.None;
        public bool startEnabled = true;
    }

    [Header("Post Processing Effects")]
    [SerializeField] private PostProcessEffect[] effects;

    private void Start()
    {
        foreach (PostProcessEffect effect in effects)
        {
            SetEffectState(effect, effect.startEnabled);
        }
    }

    private void Update()
    {
        if (Keyboard.current == null)
            return;

        foreach (PostProcessEffect effect in effects)
        {
            if (effect.toggleKey == Key.None)
                continue;

            if (Keyboard.current[effect.toggleKey].wasPressedThisFrame)
            {
                ToggleEffect(effect);
            }
        }
    }

    private void ToggleEffect(PostProcessEffect effect)
    {
        if (effect.material == null || string.IsNullOrEmpty(effect.keyword))
            return;

        bool isEnabled = effect.material.IsKeywordEnabled(effect.keyword);
        SetEffectState(effect, !isEnabled);
    }

    private void SetEffectState(PostProcessEffect effect, bool enabled)
    {
        if (effect.material == null || string.IsNullOrEmpty(effect.keyword))
            return;

        if (enabled)
            effect.material.EnableKeyword(effect.keyword);
        else
            effect.material.DisableKeyword(effect.keyword);
    }
}