import { getHost, getCookie, getPartial } from "../config.js";
import { setNavbar } from "../navbar/navbar.js";

const login = document.getElementById("login");
const email = document.getElementById("email");
const notified = document.getElementById("notified");

const password = document.getElementById("password");
const new_password = document.getElementById("newPassword");

const form = document.querySelector("form");
const confirmationDiv = document.querySelector("#confirmationDiv");
const confirmationMessage = document.querySelector("#confirmationMessage");

const host = await getHost("../config.json");
const token = getCookie("token");
if (token == "")
	window.location.href = '../index.html';

await getPartial("navbar", "../navbar/navbar.html").then(() => {
  setNavbar();
});

getUser(host);

function getUser(host) 
{
  fetch(`http://${host}:1337/user`, {
    method: "POST",
    headers: {
      // 'Content-Type': 'application/json',
    },
    body: JSON.stringify({ token: token }),
  })
    .then((response) => {
      if (response.ok) return response.json();
      else return Promise.reject(response.json());
    })
    .then((data) => {
      console.log(data);
      login.value = data.login;
      email.value = data.email;
      notified.checked = data.notified == "t" ? true : false;
    })
    .catch(async (error) => {
      let data = await error;
      console.error("error:", data);
    });
}

// document.addEventListener("DOMContentLoaded", async function(event) {

// 	console.log("HELLO FROM USER SETTINGS PAGE");
// 	await getPartial('navbar', './navbar.html')
// 	.then(() => {

// 		setNavbar();
// 	});
// });

function updateSettings() 
{
  let data = 
  {
    token: token,
    login: login.value,
    email: email.value,
    notified: notified.checked,
  };

  fetch(`http://${host}:1337/update_settings`, {
    method: "POST",
    headers: {
      // 'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  })
    .then((response) => {
      if (response.ok) 
	  	return response.json();
      else 
	  	return Promise.reject(response.json());
    })
    .then((data) =>
	{
		getUser(host);
      confirmationDiv.style.display = "";
      confirmationMessage.innerHTML = "";
      console.log("success:", data);
      setTimeout(() => {
        confirmationDiv.style.display = "none";;
      }, "1500")
      
    })
    .catch(async (error) => {
      data = await error;
      window.alert(data.error);
      console.error("error:", data);
    });
}

document.getElementById("updateBtn").addEventListener("click", () => {
  updateSettings();
});

function updatePassword() {
  let data = {
    token: token,
    password: password.value,
    new_password: new_password.value,
  };

  fetch(`http://${host}:1337/update_password`, {
    method: "POST",
    headers: {
      // 'Content-Type': 'application/json',
    },
    body: JSON.stringify(data),
  })
    .then((response) => {
      if (response.ok) return response.json();
      else return Promise.reject(response.json());
    })
    .then((data) => {
      confirmationDiv.style.display = "";
      confirmationMessage.innerHTML = "";
      console.log("success:", data);
      password.value = new_password.value;
      new_password.value = "";
      setTimeout(() => {
        confirmationDiv.style.display = "none";;
      }, "1500")
    })
    .catch(async (error) => {
      data = await error;
      window.alert(data.error);
      console.error("error:", data);
    });
}

document.getElementById("updateBtnPassword").addEventListener("click", () => {
  updatePassword();
});
