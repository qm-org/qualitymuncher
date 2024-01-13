const mainButtonsDiv = document.getElementById("mainButtons");
const batchBtn = document.getElementById("batchBtn");
const goBtn = document.getElementById("goBtn");
const additionalOptionsDiv = document.getElementById("additionalOptions");
const backBtn = document.getElementById("backBtn");

batchBtn.addEventListener("click", () => showAdditionalOptions("Batch"));
goBtn.addEventListener("click", () => showAdditionalOptions("Go"));
backBtn.addEventListener("click", resetOptions);

function showAdditionalOptions(selectedOption) {
    mainButtonsDiv.style.display = "none"; // Hide the original buttons
    backBtn.style.display = "block"; // Show the "Back" button
    customTextBtn.style.display = "none"; // Hide the "What's the difference?" text

    additionalOptionsDiv.innerHTML = "";

    const option1 = document.createElement("button");
    const option2 = document.createElement("button");

    if (selectedOption === "Batch") {
        option1.textContent = "Automated Installer";
        option2.textContent = "Manual Download";
        option1.addEventListener("click", () => showAutomatedInstaller());
        option2.addEventListener("click", () => {
            window.open(
                "https://raw.githubusercontent.com/qm-org/qualitymuncher/main/Quality%20Muncher.bat",
                "_blank"
            );
        });
    } else if (selectedOption === "Go") {
        option1.textContent = "Executable (requires FFmpeg)";
        option2.textContent = "GitHub";
        option1.addEventListener("click", () => {
            window.open(
                "https://github.com/qm-org/qm-go/releases/download/v1.0.1/qm-go.exe",
                "_blank"
            );
        });
        option2.addEventListener("click", () => {
            window.open("https://go.qualitymuncher.lgbt", "_blank");
        });
    }

    additionalOptionsDiv.appendChild(option1);
    additionalOptionsDiv.appendChild(option2);
}

function resetOptions() {
    mainButtonsDiv.style.display = "flex"; // Show the original buttons again
    backBtn.style.display = "none"; // Hide the "Back" button
    customTextBtn.style.display = "block"; // Show the "What's the difference?" text
    additionalOptionsDiv.innerHTML = ""; // Clear any additional options
}

function showAutomatedInstaller() {
    mainButtonsDiv.style.display = "none"; // Hide the original buttons

    additionalOptionsDiv.innerHTML = "";
    const automatedInstallerText = document.createElement("p");
    automatedInstallerText.innerHTML =
        'Press WIN + R, then type in <span class="highlight" id="copy">powershell "iex(iwr -useb install.qualitymuncher.lgbt)"</span> and press enter. This text has been automatically copied.';
    additionalOptionsDiv.appendChild(automatedInstallerText);
    document.getElementById("boldStuff").classList.add("fadein");
    document.getElementById("soldBuff").classList.add("gone");
    var str = document.getElementById("copy");
    window.getSelection().selectAllChildren(str);
    document.execCommand("Copy");
}
