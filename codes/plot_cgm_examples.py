from pathlib import Path
import json
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime


def load_cgm_json(json_path: Path) -> pd.DataFrame:
    """Load a dexcom JSON file and return a DataFrame with datetime and glucose value."""
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    records = []
    for rec in data.get('body', {}).get('cgm', []):
        try:
            ts = rec['effective_time_frame']['time_interval']['start_date_time']
            val = rec['blood_glucose']['value']
            records.append({'datetime': pd.to_datetime(ts), 'glucose': val})
        except Exception:
            # skip malformed entries
            continue

    df = pd.DataFrame(records)
    if not df.empty:
        # coerce glucose to numeric (some entries are strings like 'High')
        df['glucose'] = pd.to_numeric(df['glucose'], errors='coerce')
        df = df.dropna(subset=['glucose'])
        df = df.sort_values('datetime').reset_index(drop=True)
    return df


def plot_participant(df: pd.DataFrame, participant_id: str, age: int, study_group: str, out_path: Path):
    """Create and save a simple time-series plot of CGM values with metadata in the title."""
    plt.figure(figsize=(10, 3.5))
    plt.plot(df['datetime'], df['glucose'], lw=0.8)
    plt.scatter(df['datetime'], df['glucose'], s=6)
    plt.xlabel('Time')
    plt.ylabel('Glucose (mg/dL)')
    title = f"ID: {participant_id}  |  Age: {age}  |  Group: {study_group}"
    plt.title(title)
    plt.tight_layout()
    out_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=150)
    plt.close()


def main(base_dir: Path = Path(__file__).resolve().parents[1] / 'data'):
    # Paths
    dex_path = base_dir / 'wearable_blood_glucose' / 'continuous_glucose_monitoring' / 'dexcom_g6'
    participants_tsv = base_dir / 'participants.tsv'

    if not dex_path.exists():
        raise FileNotFoundError(f"Dexcom path not found: {dex_path}")

    # read participants metadata
    participants = pd.read_csv(participants_tsv, sep='\t')
    participants = participants.set_index('participant_id')

    # list participant folders and pick first five
    p_folders = sorted([p for p in dex_path.iterdir() if p.is_dir()])
    sample_folders = p_folders[:5]

    out_dir = Path(__file__).resolve().parent / 'outputs'

    for p in sample_folders:
        pid = p.name
        # find json file
        json_files = list(p.glob('*_DEX.json'))
        if not json_files:
            continue
        df = load_cgm_json(json_files[0])
        if df.empty:
            continue

        # metadata: use participants.tsv; if missing, set defaults
        if int(pid) in participants.index or pid in participants.index:
            # participant ids in TSV are numeric; try both
            try:
                meta = participants.loc[int(pid)]
            except Exception:
                meta = participants.loc[pid]
            age = int(meta.get('age', -1))
            study_group = str(meta.get('study_group', 'unknown'))
        else:
            age = -1
            study_group = 'unknown'

        out_path = out_dir / f"{pid}.png"
        plot_participant(df, pid, age, study_group, out_path)


if __name__ == '__main__':
    main()
