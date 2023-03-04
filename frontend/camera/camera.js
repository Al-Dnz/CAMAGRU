import { getHost, getCookie, coucou } from '../config.js';
// import coucou from '../config.js';

(async () => {
  // La largeur et la hauteur de la photo capturée. On utilisera
  // une largeur fixe et on calculera la hauteur pour correspondre
  // aux proportions du flux vidéo d'entrée.

  const width = 320; // On met à l'échelle la photo pour avoir cette largeur
  let height = 0; // On calcule cette valeur ensuite selon le flux d'entrée

  // |streaming| indique si le flux vidéo est en cours
  // Lorsqu'on commence, ce n'est pas le cas (false).

  let streaming = false;

  // On référence les éléments HTML qu'il faudra configurer ou contrôler.
  // Ils seront définis lors de la fonction startup().

  let video = null;
  let canvas = null;
  let photo = null;
  let startbutton = null;
  let postUploadBtn = null
  let varBlob = null; 
  let host =null;

  // async function getHost(path) {
  //   let host;
  //   await fetch(path)
  //     .then((response) => response.json())
  //     .then((data) => { host = data.host })
  //   return host;
  // }


  function showViewLiveResultButton() {
    if (window.self !== window.top) {
      // On s'assure que si notre document est dans une iframe,
      // on invite la personne à ouvrir l'exemple dans un onglet
      // ou une fenêtre séparée. Sinon, le navigateur n'envoie
      // pas la demande d'accès à la caméra.
      document.querySelector(".contentarea").remove();
      const button = document.createElement("button");
      document.body.append(button);
      button.addEventListener("click", () => window.open(location.href));
      return true;
    }
    return false;
  }

  async function startup() {
    if (showViewLiveResultButton()) {
      return;
    }
    video = document.getElementById("video");
    canvas = document.getElementById("canvas");
    photo = document.getElementById("photo");
    startbutton = document.getElementById("startbutton");
	postUploadBtn = document.getElementById("postUpload")
	host = await getHost("../config.json");
  console.log("CAMHOST=> "+ host);
	
    navigator.mediaDevices
      .getUserMedia({ video: true, audio: false })
      .then((stream) => {
        video.srcObject = stream;
        video.play();
      })
      .catch((err) => {
        console.error(`Une erreur est survenue : ${err}`);
      });

    video.addEventListener(
      "canplay",
      (ev) => {
        if (!streaming) {
          height = video.videoHeight / (video.videoWidth / width);

          // Firefox a un bug où la hauteur ne peut pas être lue
          // à partir de la vidéo. On prend des précautions.

          if (isNaN(height)) {
            height = width / (4 / 3);
          }

          video.setAttribute("width", width);
          video.setAttribute("height", height);
          canvas.setAttribute("width", width);
          canvas.setAttribute("height", height);
          streaming = true;
        }
      },
      false
    );

    startbutton.addEventListener(
      "click",
      async (ev) => {
        varBlob = await takepicture();
        ev.preventDefault();
      },
      false
    );

	postUploadBtn.addEventListener("click",
		(ev) => {
		  postUpload(varBlob);
		  ev.preventDefault();
		},
		false
	  );

    clearphoto();
  }

  // On remplit le cadre de la photo pour indiquer l'absence
  // d'image capturée.

  function clearphoto() {
    const context = canvas.getContext("2d");
    context.fillStyle = "#AAA";
    context.fillRect(0, 0, canvas.width, canvas.height);

    const data = canvas.toDataURL("image/png");
    photo.setAttribute("src", data);
  }

  // On capture une photo en récupérant le contenu courant de la
  // vidéo, qu'on dessine dans un canevas puis qu'on convertit
  // en une URL de données contenant l'image au format PNG.
  // En utilisant un canevas en dehors de l'écran, on peut
  // modifier sa taille et/ou appliquer d'autres modifications
  // avant de l'afficher à l'écran.	


    async function takepicture() {
		const context = canvas.getContext("2d");
		if (width && height) {
		canvas.width = width;
		canvas.height = height;
		context.drawImage(video, 0, 0, width, height);

		const data = canvas.toDataURL("image/png");
		photo.setAttribute("src", data);

		const blob = await new Promise(resolve => canvas.toBlob(resolve));
		return blob

		} else {
			clearphoto();
		}
  }



function postUpload(blob)
{
	console.log(host);
	if (!blob)
	{
		console.error("no blob loaded")
		return;
	}
	fetch(`http://${host}:1337/pictures`, {
		method: "POST",
		headers: {
			'Content-Type': 'multipart/form-data',
		},
		body: varBlob,
	})
	.then((response) => {
		if (response.ok)
			 return response.json();
		else
			return Promise.reject(response.json()); 
	  })
	.then((data) => {
		console.log('success:', data);
		varBlob = null;
		// var img = document.querySelector('#myImg');
		// URL.revokeObjectURL(img.src);
		// img.src = "";
	})
	// .catch(async (error) => {
	// 	data = await error;
	// 	console.error('error:', data.error); 
	// });
}

  // On met en place un gestionnaire d'évènement pour exécuter
  // le code lorsque le chargement du document est terminé.
  window.addEventListener("load", startup, false);
  
})();
