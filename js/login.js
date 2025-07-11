const apiUrl = `http://${window.location.hostname}:5000`;

document.getElementById("loginForm").onsubmit = async (event) => {
    event.preventDefault();

    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;
    const message = document.getElementById("responseMessage");

    const response = await fetch(apiUrl + "/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
        credentials: 'include'
    });

    if (response.status == 200) {
        message.innerText = "Login successful!";
        message.style.color = "green";
        setTimeout(async () => {
            window.location.href = await response.text();
        }, 1000);
    } else if (response.status == 401) {
        message.innerText = "Invalid username or password";
        message.style.color = "red";
    } else if (response.status == 403) {
        message.innerText = "Profile incomplete, please select role";
        message.style.color = "red";
        const select = `<label for="role">Select role:</label>
                        <select id="role" required>
                            <option value="Stapan">Stapan</option>
                            <option value="Medic">Medic</option>
                        </select><br>`;
        document.querySelector("button").insertAdjacentHTML('beforebegin', select);
        document.getElementById("loginForm").onsubmit = (event) => {
            event.preventDefault();
            setTimeout(() => {
                window.location.href = "Register" + document.getElementById("role").value + ".html";
            }, 500);
        };
    } else {
        message.innerText = "Internal server error, please try again later";
        message.style.color = "red";
    }
};