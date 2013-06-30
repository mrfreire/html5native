function callNative(functionName)
{
	var iframe = document.createElement("IFRAME");
	/*iframe.setAttribute("src", "js-frame:" + functionName + ":" + callbackId+ ":" + encodeURIComponent(JSON.stringify(args)));*/
	iframe.setAttribute("src", "jsb://" + functionName);
	document.documentElement.appendChild(iframe);
	iframe.parentNode.removeChild(iframe);
	iframe = null;
}
