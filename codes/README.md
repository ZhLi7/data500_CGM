Usage
-----

This `codes/` folder contains a small example script and notebook to generate example CGM time-series plots for five participants.

Files:
- `plot_cgm_examples.py` — script that locates dexcom JSON files, extracts the time series, and saves PNG plots to `codes/outputs/`.
- `plot_cgm_examples.ipynb` — lightweight notebook that installs dependencies and runs the script.
- `outputs/` — directory where PNGs are written.

How to run (recommended in the project root and with the project's virtual environment):

In terminal (from repo root):

```bash
# activate your venv if needed, then
python codes/plot_cgm_examples.py
```

Or open `codes/plot_cgm_examples.ipynb` and run the cells.

Notes and assumptions:
- Participant name is not available in the data; the code uses `participant_id` as the display name.
- Age and study group are read from `data/participants.tsv` when available.
- The script picks the first five participant folders found under `data/wearable_blood_glucose/continuous_glucose_monitoring/dexcom_g6/`.
