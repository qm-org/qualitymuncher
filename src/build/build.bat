@echo off
set version=1.0.0
cd ..
py -m nuitka --assume-yes-for-downloads --warn-unusual-code --warn-implicit-exceptions --include-plugin-files="main.py" --include-plugin-files="executioner.py" --include-plugin-files="helpers.py" --include-plugin-files="muncher.py" --include-plugin-files=".\plugins\colors.py" --onefile --standalone --remove-output --windows-company-name=QM --windows-product-name="Python runtime" --windows-file-version="%version%" --windows-product-version="%version%" --windows-file-description="Python runtime for Quality Muncher" -o qm.exe runtime.py
pause