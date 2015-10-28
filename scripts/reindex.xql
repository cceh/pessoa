xquery version "1.0";

(: update the database index after modifying collection.xconf :)

xmldb:reindex('/db/apps/pessoa/data/doc'),
xmldb:reindex('/db/apps/pessoa/data/pub')