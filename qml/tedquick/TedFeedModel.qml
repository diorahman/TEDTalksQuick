import QtQuick 1.1

// bytes to megabytes 1048576

XmlListModel {
    id: tedModel
    query: "/rss/channel/item"
    namespaceDeclarations: "declare namespace itunes=\"http://www.itunes.com/dtds/podcast-1.0.dtd\";" +
                           "declare namespace media=\"http://search.yahoo.com/mrss/\";" +
                           "declare namespace feedburner=\"http://rssnamespace.org/feedburner/ext/1.0\";"

    XmlRole { name: "title"; query: "title/string()" }
    XmlRole { name: "author"; query: "itunes:author/string()" }
    XmlRole { name: "summary"; query: "itunes:summary/string()" }
    XmlRole { name: "subtitle"; query: "itunes:subtitle/string()" }
    XmlRole { name: "link"; query: "link/string()" }
    XmlRole { name: "guid"; query: "guid/string()" }
    XmlRole { name: "pubDate"; query: "pubDate/string()" }
    XmlRole { name: "duration"; query: "itunes:duration/string()" }
    XmlRole { name: "mediaUrl"; query: "media:content/@url/string()" }
    XmlRole { name: "mediaSize"; query: "media:content/@fileSize/string()" }
    XmlRole { name: "imageSmall"; query: "media:thumbnail/@url/string()" }
    XmlRole { name: "imageBig"; query: "itunes:image/@url/string()" }
    XmlRole { name: "mediaEncUrl"; query: "enclosure/@url/string()" }
    XmlRole { name: "mediaEncSize"; query: "enclosure/@length/string()" }
    XmlRole { name: "origUrl"; query: "feedburner:origLink/string()" }
    XmlRole { name: "origLink"; query: "feedburner:origEnclosureLink/string()" }
}
