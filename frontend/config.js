async function getHost(path){
	let host;
	await fetch(path)
		.then((response) => response.json())
		.then((data) => {host = data.host})
	return host;
}

export { getHost as default};



