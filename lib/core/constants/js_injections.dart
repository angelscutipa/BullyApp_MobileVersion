class JSInjections {
  static const String antiReactNfcStyle = r'''
    (function() {
      let style = document.getElementById('anti-react-nfc-style');
      if (!style) {
        style = document.createElement('style');
        style.id = 'anti-react-nfc-style';
        document.head.appendChild(style);
      }
      
      style.innerHTML = `
        [title*="Vincular chip NFC"],
        [data-title*="Vincular chip NFC"],
        [aria-label*="Vincular chip NFC"],
        button:has([title*="Vincular chip NFC"]),
        button:has([data-title*="Vincular chip NFC"]),
        .nfc-link-button,
        a[href*="nfc"] {
          display: none !important;
          visibility: hidden !important;
          pointer-events: none !important;
          opacity: 0 !important;
          position: absolute !important;
          left: -9999px !important;
        }
      `;
      
      console.log("🛡️ Estilo Anti-React inyectado/actualizado");

      const observer = new MutationObserver(() => {
        const elements = document.querySelectorAll('[title*="Vincular chip NFC"], [data-title*="Vincular chip NFC"]');
        elements.forEach(el => {
          if (el.style.display !== 'none') {
            el.style.setProperty('display', 'none', 'important');
          }
        });
      });

      observer.observe(document.body, { 
        childList: true, 
        subtree: true
      });
    })();
  ''';

  static const String metaViewport = r'''
    if (!document.querySelector('meta[name="viewport"]')) {
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
    }
  ''';

  static const String antiDownloadApp = r'''
    (() => {
      function removeButton() {
        document.querySelectorAll('button').forEach(btn => {
          if (btn.textContent && btn.textContent.includes('Descargar App')) {
            btn.remove();
          }
        });
      }
      removeButton();
      
      if (document.body) {
        const observer = new MutationObserver(removeButton);
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      }
    })();
  ''';

  static const String fetchSessionToken = r'''
    (async function() {
      try {
        function getCookie(name) {
          const value = `; ${document.cookie}`;
          const parts = value.split(`; ${name}=`);
          if (parts.length === 2) {
            return decodeURIComponent(parts.pop().split(';').shift());
          }
          return '';
        }

        const xsrfToken = getCookie('XSRF-TOKEN');
        const res = await fetch('/web/api/token', {
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-XSRF-TOKEN': xsrfToken
          }
        });

        if (res.ok) {
          const resData = await res.json();
          if (resData.status === 'success' && resData.data && resData.data.token) {
            console.log('🔑 [JS WebView] Token obtenido de Sanctum:', resData.data.token);
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('onTokenReceived', resData.data);
            }
          }
        } else {
          console.log('Obtención de token fallida con status:', res.status);
        }
      } catch (e) {
        console.error('Error al obtener token de sesión:', e);
      }
    })();
  ''';

  static const String hideWebFooter = r'''
    (function() {
      function injectHideStyle() {
        let style = document.getElementById('hide-web-footer-style');
        if (!style) {
          style = document.createElement('style');
          style.id = 'hide-web-footer-style';
          if (document.head) {
            document.head.appendChild(style);
          } else if (document.documentElement) {
            document.documentElement.appendChild(style);
          }
        }
        if (style) {
          style.innerHTML = `
            div.fixed.inset-x-0.bottom-0,
            div.fixed.bottom-0.z-50,
            div[class*="fixed"][class*="bottom-0"][class*="z-50"] {
              display: none !important;
              visibility: hidden !important;
              pointer-events: none !important;
              opacity: 0 !important;
              height: 0 !important;
              overflow: hidden !important;
            }
          `;
        }
      }

      function removeWebFooter() {
        injectHideStyle();
        const footers = document.querySelectorAll('div.fixed.bottom-0, div.fixed.inset-x-0.bottom-0, div[class*="fixed"][class*="bottom-0"]');
        footers.forEach(footer => {
          if (footer.querySelector('a[href*="/idrb"], a[href*="/bullys"], a[href*="/kennels"], a[href*="/search-nfc"], a[href*="/marketplace"], [aria-label*="Soporte BullyApp"]')) {
            footer.style.setProperty('display', 'none', 'important');
            footer.remove();
          }
        });
      }

      injectHideStyle();
      removeWebFooter();

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', removeWebFooter);
      }

      if (document.body) {
        const observer = new MutationObserver(removeWebFooter);
        observer.observe(document.body, { childList: true, subtree: true });
      } else {
        document.addEventListener('DOMContentLoaded', () => {
          if (document.body) {
            const observer = new MutationObserver(removeWebFooter);
            observer.observe(document.body, { childList: true, subtree: true });
          }
        });
      }
    })();
  ''';
}
