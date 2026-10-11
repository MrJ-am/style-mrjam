/* Cycle de vie du SDK Vimeo existant et de l'iframe créée par Elm.
   Aucune présentation, création de DOM, bouton ou horloge d'animation. */
(() => {
  "use strict";
  class LecteurVideo extends HTMLElement {
    connectedCallback() {
      queueMicrotask(() => { if (this.isConnected) this.connecter(); });
    }
    disconnectedCallback() { this.arreter(); }
    arreter() {
      this.version = (this.version || 0) + 1;
      clearTimeout(this.delai);
      const ancien = this.lecteur;
      this.lecteur = null;
      if (ancien) Promise.resolve(ancien.destroy()).catch(() => {});
    }
    async connecter() {
      this.arreter();
      const version = this.version;
      const courant = () => this.isConnected && this.version === version;
      const iframe = this.querySelector("iframe");
      let echec = false;
      const evenement = (type, autres = {}) => {
        if (courant()) this.dispatchEvent(new CustomEvent("video-etat", { detail: { type, ...autres }, bubbles: true }));
      };
      const echouer = () => {
        if (echec || !courant()) return;
        echec = true;
        clearTimeout(this.delai);
        evenement("erreur");
      };
      this.delai = setTimeout(echouer, 15000);
      try {
        if (!iframe) throw new Error("Surface vidéo absente");
        const url = new URL(iframe.src);
        if (url.protocol !== "https:" || !["player.vimeo.com", "www.youtube-nocookie.com"].includes(url.hostname) || url.username || url.password || (url.port && url.port !== "443")) throw new Error("Source vidéo invalide");
        if (url.hostname === "www.youtube-nocookie.com") {
          clearTimeout(this.delai);
          evenement("pret");
          iframe.focus({ preventScroll: true });
          return;
        }
        if (!window.Vimeo?.Player) throw new Error("SDK local indisponible");
        const lecteur = new window.Vimeo.Player(iframe);
        this.lecteur = lecteur;
        lecteur.on("timeupdate", ({ seconds }) => { if (!echec) evenement("position", { secondes: seconds }); });
        lecteur.on("ended", () => { if (!echec) evenement("termine"); });
        lecteur.on("error", ({ name }) => { if (name === "PrivacyError") echouer(); });
        await lecteur.ready();
        if (!courant() || echec) return;
        clearTimeout(this.delai);
        evenement("pret");
        iframe.focus({ preventScroll: true });
      } catch { echouer(); }
    }
  }
  if (!customElements.get("course-video")) customElements.define("course-video", LecteurVideo);
})();
