# Subset10 — 10% sample of dataset

Source dataset: /Users/zhongyuli/Library/CloudStorage/OneDrive-Emory/Research Projects_Shared/T2D CGM/working/AiREAD_V2/dataset
Subset created at: /Users/zhongyuli/Library/CloudStorage/OneDrive-Emory/Research Projects_Shared/T2D CGM/working/AiREAD_V2/subset10
Sampling fraction: 0.1
Random seed: 42
Number of participants sampled: 105

Contents:
- `wearable_blood_glucose/continuous_glucose_monitoring/dexcom_g6/` — copied participant folders (full contents).
- `clinical_data/` — clinical CSVs filtered by `person_id` to only include sampled participants (where possible).
- `participants.tsv` — filtered participants file for the sampled participants.
- `sampled_participants.txt` — list of sampled participant IDs (one per line).
- `demo_notebook.ipynb` — a small notebook demonstrating how to load a CGM file and matched clinical rows from this subset.

Notes:
- The original `dataset` directory was not modified. This subset is a copy generated for convenience and reproducibility.
- If you need a different sampling fraction or seed, update and re-run the script.