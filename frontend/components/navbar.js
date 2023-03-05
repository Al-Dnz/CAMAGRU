import { getCookie } from '../config.js';

function setNavbar() 
{
	const settingsBtn = document.getElementById("settingsBtn");
	const picBtn = document.getElementById("picBtn");
	const powerBtn = document.getElementById("powerBtn");

	if (getCookie("token") != "") {
		picBtn.style.display = "";
		settingsBtn.style.display = "";
		powerBtn.querySelector("svg").classList.add("text-white");
		powerBtn.status = "on";
	}


	powerBtn.addEventListener("click", () => {
		if (powerBtn.status == "on") {
			document.cookie = "token" + "=";
			window.location.replace("./index.html");
		}
		else {
			window.location.replace("./connect.html");
		}
	});

}

export { setNavbar };





