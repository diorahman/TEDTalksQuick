
var xhr = new XMLHttpRequest();
var item;

function setItem(aitem) {
    item = aitem;
}

function abort() {
    xhr.abort();
}

function fetch(path, type) {

    var url = ""
    if(type=="path")
        url = "http://aegis.no.de/ted/subtitles?path=" + path
    else
        url = "http://www.ted.com/talks/subtitles/id/"+ path.id +"/lang/" + path.code;

    xhr.open("GET",url,true);
    xhr.onreadystatechange = function()
    {
        if ( xhr.readyState == xhr.DONE )
        {
            if ( xhr.status == 200 )
            {
                var jsonObject = JSON.parse(xhr.responseText);
                item.ended(jsonObject, type);
            }
            else
            {
                item.error();
            }
        }
    }

    xhr.send();
    item.started();
}
