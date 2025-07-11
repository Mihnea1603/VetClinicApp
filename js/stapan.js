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

const fetchData = async (tableName) => {
    const response = await fetch(apiUrl + "/stapan/" + tableName, {
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

document.getElementById("deleteVaccinareForm").onsubmit = async function (event) {
    event.preventDefault();

    const numeAnimal = document.getElementById("numeAnimal").value;
    const numeVaccin = document.getElementById("numeVaccin").value;
    const message = document.getElementById("responseMessage1");

    const response = await fetch(apiUrl + "/stapan/vaccinari/delete", {
        method: "DELETE",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ numeAnimal, numeVaccin }),
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

document.getElementById("updateContForm").onsubmit = async function (event) {
    event.preventDefault();

    const numeColoana = document.getElementById("numeColoana").value;
    const nouaValoare = document.getElementById("nouaValoare").value;
    const message = document.getElementById("responseMessage2");

    const response = await fetch(apiUrl + "/stapan/cont/update", {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ numeColoana, nouaValoare }),
        credentials: "include",
    });

    if (response.status == 204) {
        this.reset();
        message.innerText = "";
        fetchData("cont");
    } else if (response.status == 400) {
        message.innerText = "Invalid column name!";
        message.style.color = "red";
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};

fetchData("animale");
fetchData("consultatii");
fetchData("vaccinari");
fetchData("cont");