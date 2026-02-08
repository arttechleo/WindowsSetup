# TA Quiet 25 — Baseline fan curve (manual steps)

Human steps to set a quiet baseline fan curve in the fan control GUI. Use after the tool is running (e.g. via TA-Fans-OnLogon).

## Goal

- Quieter operation at idle and light load.
- “25” refers to a target baseline (e.g. 25% or step 25); adjust to your preference.

## Steps (in the GUI)

1. Open the fan control application (it may already be running minimized in the tray).
2. Locate the fan curve / custom curve editor.
3. Set a baseline curve:
   - At 0–40 °C (or equivalent): low fan % (e.g. 20–25%).
   - Ramp up gradually between 40–70 °C.
   - Above 70 °C: steeper ramp or 100% as needed.
4. Name the profile something like **TA-Quiet-25-Baseline** and save it in the app if the tool supports profiles.
5. Apply and minimize; the scheduled task will start this minimized at next logon.

## Notes

- Exact steps depend on the specific fan control software you use (not included in this repo).
- Keep an eye on temperatures under load; increase fan curve if needed.
