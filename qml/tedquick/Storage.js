
function openDatabase() {
    return openDatabaseSync("labs.aegis.tedquick", "1.0", "storage for TED-quick", 100000)
}

function initialize() {
    var db = openDatabase()
    db.transaction(
                function(tx) {
                    tx.executeSql("CREATE TABLE IF NOT EXISTS archive(guid TEXT UNIQUE, metadata TEXT)")
                    tx.executeSql("CREATE TABLE IF NOT EXISTS settings(key TEXT UNIQUE, value TEXT)")
                }
                )
}

function dropAllTables() {
    var db = openDatabase();
    db.transaction(function(tx){
                       tx.executeSql("DROP TABLE archive")
                       tx.executeSql("DROP TABLE settings")
                   }
                   )
}

function addArchive(guid, metadata) {
    var db = openDatabase()
    var res = "Error"
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql("INSERT OR REPLACE INTO archive VALUES (?,?);", [guid, metadata])
                    if (rs.rowsAffected > 0)
                        res = "OK"
                }
                )
    return res
}

function loadArchive(model) {
    var db = openDatabase()
    var res = "Unknown"
    db.transaction(
                function(tx)
                {
                    var rs = tx.executeSql("SELECT * FROM archive")
                    if (rs.rows.length > 0)
                    {
                        //console.log('archive count ' + rs.rows.length);
                        model.clear();
                        for (var i = 0; i < rs.rows.length; i++ )
                        {
                            model.append(JSON.parse(rs.rows.item(i).metadata));
                        }

                        res="OK"
                    }
                }
                )
    return res
}

function updateArchiveDetail(guid, metadata) {
    var db = openDatabase()
    var res = "Error"
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql("UPDATE archive SET metadata=? WHERE guid=?;", [metadata, guid])
                    if (rs.rowsAffected > 0)
                        res = "OK"
                }
                )
    return res
}

function exist(guid) {
    var db = openDatabase();
    var res= false;
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT * FROM archive WHERE guid=?;', [guid]);
                    if (rs.rows.length > 0) {
                        res = true;
                    }
                }
                )
    return res
}

function deleteArchiveByGuid(guid) {
    var db = openDatabase()
    var res = "Error"
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql("DELETE FROM archive WHERE guid=?;", [guid])
                }
                )
    return res
}

function deleteArchive()
{
    var db = openDatabase()
    db.transaction(
                function(tx) {
                    tx.executeSql("DELETE FROM archive")
                }
                )
}

function setSetting(key, value) {
    var db = openDatabase()
    var res = "Error"
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql("INSERT OR REPLACE INTO settings VALUES (?,?);", [key,value])
                    if (rs.rowsAffected > 0)
                        res = "OK"
                }
                )
    return res
}

function deleteSetting(key) {
    var db = openDatabase();
    var res="Error";
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('DELETE FROM settings WHERE key=?;', [key]);
                    if (rs.rows.length > 0)
                    {
                        res="OK"
                    }
                }
                )
    return res
}

function getSetting(key, defaultVal) {
    var db = openDatabase();
    var res="";
    db.transaction(
                function(tx) {
                    var rs = tx.executeSql('SELECT value FROM settings WHERE key=?;', [key]);
                    if (rs.rows.length > 0) {
                        res = rs.rows.item(0).value;
                    } else {
                        res = defaultVal;
                    }
                }
                )
    return res
}
