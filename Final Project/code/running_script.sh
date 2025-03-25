models=(
'hf_hub:timm/deit3_large_patch16_224.fb_in22k_ft_in1k'
'hf_hub:timm/vit_mediumd_patch16_reg4_gap_384.sbb2_e200_in12k_ft_in1k'
'convnext_xxlarge.clip_laion2b_soup_ft_in1k'
'resnext101_32x32d.fb_wsl_ig1b_ft_in1k'
"hf_hub:timm/eva02_large_patch14_448.mim_m38m_ft_in22k_in1k"
'vit_huge_patch14_clip_336.laion2b_ft_in12k_in1k'
'vit_large_patch14_clip_224.openai_ft_in1k'
)

counter=1

for model in "${models[@]}"; do
    echo -e "\n========================================\n\n"
    echo -e "STARTING RUN #$counter\n"
    echo -e "\n========================================\n\n"
    python3 bash_helper.py "$model"
    sleep 3
    ((counter++))
done

