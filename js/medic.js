const apiUrl = `http://${window.location.hostname}:5000`;

document.getElementById("logout").onclick = async () => {
    const response = await fetch(apiUrl + "/logout", {
        method: "POST",
        credentials: 'include'
    });

    if (response.status == 204) {
        setTimeout(() => {
            window.location.href = "Login.html";
        }, 500);
    }
};

const fetchData = async (tableName, filter = null) => {
    let url = apiUrl + "/medic/" + tableName;
    if (filter) {
        url += `/${filter}`;
    }

    const response = await fetch(url, {
        method: "GET",
        credentials: 'include'
    });

    if (response.status == 200) {
        const data = await response.json();

        const table = document.getElementById(tableName + "Table");
        table.innerHTML = "";
        data.forEach(rowData => {
            const row = table.insertRow();
            rowData.forEach(value => {
                row.insertCell().textContent = value;
            });
        });
    } else if (response.status == 403) {
        document.body.innerHTML = "<h1>Access denied. Please, sign in first!</h1>";
        document.body.style.color = "red";
        setTimeout(() => {
            window.location.href = "Login.html";
        }, 1500);
    } else {
        document.body.innerHTML = "<h1>Internal server error, please try again later</h1>";
        document.body.style.color = "red";
    }
};

document.getElementById("stapaniAnimaleFilter").onclick = () => {
    const numarAnimale = document.getElementById("numarAnimale").value;
    fetchData("stapaniAnimale", numarAnimale);
};

document.getElementById("vaccinariFilter").onclick = () => {
    const numeStapan = document.getElementById("numeStapan").value;
    fetchData("vaccinari", numeStapan);
};

document.getElementById("updateVaccinareForm").onsubmit = async function (event) {
    event.preventDefault();

    const numeAnimal = document.getElementById("numeAnimal").value;
    const numeVaccinVechi = document.getElementById("numeVaccinVechi").value;
    const numeVaccinNou = document.getElementById("numeVaccinNou").value;
    const message = document.getElementById("responseMessage1");

    const response = await fetch(apiUrl + "/medic/vaccinari/update", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ numeAnimal, numeVaccinVechi, numeVaccinNou }),
        credentials: "include",
    });

    if (response.status == 204) {
        this.reset();
        message.innerText = "";
        fetchData("vaccinari");
    } else if (response.status == 404) {
        message.innerText = "No matching animal or vaccine found";
        message.style.color = "red";
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};

document.getElementById("deleteMedicamentForm").onsubmit = async function (event) {
    event.preventDefault();

    const tratamentID = document.getElementById("tratamentID").value;
    const numeMedicament = document.getElementById("numeMedicament").value;
    const message = document.getElementById("responseMessage2");

    const response = await fetch(apiUrl + "/medic/tratamenteMedicamente/delete", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ tratamentID, numeMedicament }),
        credentials: "include",
    });

    if (response.status == 204) {
        this.reset();
        message.innerText = "";
        fetchData("tratamenteMedicamente");
    } else if (response.status == 404) {
        message.innerText = "No matching treatment or medicine found";
        message.style.color = "red";
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};

fetchData("stapaniAnimale");
fetchData("consultatii");
fetchData("vaccinari");
fetchData("tratamenteMedicamente");