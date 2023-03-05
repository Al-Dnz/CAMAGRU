async function getHost(path) {
	let host;
	await fetch(path)
		.then((response) => response.json())
		.then((data) => { host = data.host })
	return host;
};

function getCookie(cname) {
	let name = cname + "=";
	let decodedCookie = decodeURIComponent(document.cookie);
	let ca = decodedCookie.split(';');
	for (let i = 0; i < ca.length; i++) {
		let c = ca[i];
		while (c.charAt(0) == ' ') {
			c = c.substring(1);
		}
		if (c.indexOf(name) == 0) {
			return c.substring(name.length, c.length);
		}
	}
	return "";
};

async function getPartial(div, path)
{
	await fetch(path)
		.then(function(response) {return response.text()})
		.then(function(body) {document.querySelector(`#${div}`).innerHTML = body;});
};

export { getHost, getCookie, getPartial };



