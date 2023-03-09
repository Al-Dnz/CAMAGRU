
function createCard(picture) {
	const markup =
		`<div id="pictureCard${picture.id}" style="display: block" class="max-w-sm max-w-md mx-auto rounded overflow-hidden shadow-lg" data-type="picture_card_template">
			<div class="font-bold text-xl mb-2">${picture.user}</div>
			<img class="w-full" src="${picture.path}">
			<div class="px-6 py-4">
				<button>
					<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-red-500 fill-red-500">
						<path stroke-linecap="round" stroke-linejoin="round" d="M21 8.25c0-2.485-2.099-4.5-4.688-4.5-1.935 0-3.597 1.126-4.312 2.733-.715-1.607-2.377-2.733-4.313-2.733C5.1 3.75 3 5.765 3 8.25c0 7.22 9 12 9 12s9-4.78 9-12z" />
					</svg>
				</button>
				<br/>
				<hr/>
				<p class="text-gray-700 text-base"> ${picture.content} </p>
			</div>
			<div class="px-6 pt-4 pb-2">
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#photography</span>
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#travel</span>
				<span class="inline-block bg-gray-200 rounded-full px-3 py-1 text-sm font-semibold text-gray-700 mr-2 mb-2">#nonrien</span>
			</div>
		</div>`

	let div = document.createElement("div");
	div.innerHTML = markup;
	return div;
}

export { createCard as default };



