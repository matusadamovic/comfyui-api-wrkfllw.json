# clean base image containing only comfyui, comfy-cli and comfyui-manager

FROM runpod/worker-comfyui:5.5.1-base

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
RUN comfy node install --exit-on-fail cg-use-everywhere@7.5.2 --mode remote
RUN comfy node install --exit-on-fail comfyui-kjnodes@1.2.4
RUN comfy node install --exit-on-fail comfyui-gguf@1.1.9
RUN comfy node install --exit-on-fail comfyui-image-saver@1.20.0
RUN comfy node install --exit-on-fail comfyui-frame-interpolation@1.0.7
RUN comfy node install --exit-on-fail comfyui_essentials@1.1.0
RUN comfy node install --exit-on-fail rgthree-comfy@1.0.2512112053
RUN comfy node install --exit-on-fail comfyui-videohelpersuite@1.7.9
RUN comfy node install --exit-on-fail comfyui-impact-pack@8.28.2

# The following custom nodes are listed under unknown_registry in the workflow and could not be resolved automatically (no aux_id provided):
# - Bookmark (rgthree)
# - MarkdownNote
# - Note
# - Fast Groups Bypasser (rgthree)

# download models into comfyui
# Upscalers / interpolation
RUN comfy model download --url https://huggingface.co/jaideepsingh/upscale_models/blob/main/remacri_original.pth --relative-path models/upscale_models --filename remacri_original.pth
RUN comfy model download --url https://huggingface.co/hfmaster/models-moved/blob/cab6dcee2fbb05e190dbb8f536fbdaa489031a14/rife/rife49.pth --relative-path models/upscale_models --filename rife49.pth

# Text encoder + VAE (WAN repackaged)
RUN comfy model download --url https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors --relative-path models/text_encoders --filename umt5_xxl_fp8_e4m3fn_scaled.safetensors
RUN comfy model download --url https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors --relative-path models/vae --filename wan_2.1_vae.safetensors

# WAN 2.2 i2v checkpoints (fp8 scaled)
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/checkpoints/wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors --relative-path models/checkpoints --filename wan2.2_i2v_high_noise_14B_fp8_scaled.safetensors
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/checkpoints/wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors  --relative-path models/checkpoints --filename wan2.2_i2v_low_noise_14B_fp8_scaled.safetensors

# GGUF checkpoints (ComfyUI-GGUF typically uses models/gguf)
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/checkpoints_gguf/DasiwaWAN22I2V14BTastysinV8_q8High.gguf --relative-path models/gguf --filename DasiwaWAN22I2V14BTastysinV8_q8High.gguf
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/checkpoints_gguf/DasiwaWAN22I2V14BTastysinV8_q8Low.gguf  --relative-path models/gguf --filename DasiwaWAN22I2V14BTastysinV8_q8Low.gguf

# LoRAs
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors --relative-path models/loras --filename wan2.2_i2v_lightx2v_4steps_lora_v1_high_noise.safetensors
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/loras/wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors  --relative-path models/loras --filename wan2.2_i2v_lightx2v_4steps_lora_v1_low_noise.safetensors

# Optional (often embeddings / textual inversion)
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/optional/NSFW-22-H-e8.safetensors --relative-path models/embeddings --filename NSFW-22-H-e8.safetensors
RUN comfy model download --url https://huggingface.co/matadamovic/vanillamotionbotmodels/resolve/main/optional/NSFW-22-L-e8.safetensors --relative-path models/embeddings --filename NSFW-22-L-e8.safetensors

# Compatibility: if some workflows expect umt5 under models/clip, create a symlink
RUN mkdir -p models/clip && ln -sf ../text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors models/clip/umt5_xxl_fp8_e4m3fn_scaled.safetensors

# copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# COPY input/ /comfyui/input/
