#Download - Der Spiegel

Simples Skript zum Herunterladen älterer Ausgaben des Spiegels als PDFs.

##Dokumentation

Die Nutzung ist unkompliziert und funktioniert nach folgendem Schema:

    ruby download-der-spiegel.rb [year] [issue]

    # Beispiel: Download der ältesten verfügbaren Ausgabe. Jahr: 1947, Ausgabe Nr.: 1
    ruby download-der-spiegel.rb 1947 1

##Dependencies

###cURL

Für die Downloads ruft das Skript cURL auf, das sich oft schon vorinstalliert ist. Wenn nicht:

    # Unter Debian/Ubuntu
    apt-get update
    apt-get install curl

oder über die offizielle [Installationsdoku](http://curl.haxx.se/docs/install.html)

###Nokogiri

[Nokogiri](http://www.nokogiri.org/) muss ebenfalls auf dem System sein. Installation entweder "per Hand" über:

    gem install nokogiri

oder, falls vorhanden, über [Bundler](http://bundler.io/):

    bundle install

##Bekanntes Problem

Durch die Art, wie auf der Website des Spiegels auf die PDFs verlinkt wird, passiert es bei vielen Ausgaben, dass Seiten doppelt geladen werden. So kommt es vor, dass z. B. die Seiten 34, 35 und 36 einer Ausgabe in einer Datei zu finden sind, es aber noch eine extra Datei nur mit Seite 36 gibt.

Falls jemand eine unkomplizierte Lösung hierzu findet: Immer her damit ;)
