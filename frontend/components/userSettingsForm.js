import { getHost, getCookie, getPartial } from '../config.js';
import { setNavbar } from './navbar.js';

const login = document.getElementById("login");
const password = document.getElementById("password");
const email = document.getElementById("email");
const notified = document.getElementById("notified");

const form = document.querySelector("form");
const confirmationDiv = document.querySelector("#confirmationDiv");
const confirmationMessage = document.querySelector("#confirmationMessage");

const host = await getHost('../config.json')
const token =  getCookie("token");
console.log(token);

await getPartial('navbar', './components/navbar.html')
	.then(() => {		
		setNavbar();
	});

fetch(`http://${host}:1337/user`, {
	
	method: 'POST',
	headers: {
		// 'Content-Type': 'application/json',
	},
	body: JSON.stringify({token: token}),
})
.then((response) => {
	if (response.ok)
			return response.json();
		else
			return Promise.reject(response.json()); 
	  })
.then((data) => {
	console.log(data);
	login.value = data.login;
	email.value = data.email;
	notified.checked = data.notified == "t" ? true : false;

})
// .catch(async (error) => {
// 		let data = await error;
// 		console.error('error:', data); 
// });



// document.addEventListener("DOMContentLoaded", async function(event) { 
	
// 	console.log("HELLO FROM USER SETTINGS PAGE");
// 	await getPartial('navbar', './navbar.html')
// 	.then(() => {
		
// 		setNavbar();
// 	});
// });



function send()
{
	let data = 
	{
		login: login.value,
		password: password.value,
		email: email.value
	}

	fetch(`http://${host}:1337/register`, {
		method: 'POST',
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
	.then((data) => {
		form.style.display = "none"; 
		confirmationDiv.style.display = "";
		confirmationMessage.innerHTML = `A confirmation mail has been sent to ${data.email}`;
		console.log('success:', data);
		login.value = "";
		password.value = "";
		email.value  = "";
	})
	.catch(async (error) => {
		data = await error;
		window.alert(data.error);
		console.error('error:', data.error); 
	});
}

document.getElementById("updateBtn").addEventListener("click",() => {send()});