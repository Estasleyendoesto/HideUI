--[[
    Este será un template para cada frame (excluyendo los chats)
    FrameManager se encargará solo de gestionar cada template de los frames de manera global, es decir:
        - Enviando eventos como estados
        - Actualizando sus propiedades tras un cambio en la DB
        - Activando o desactivando sus funcionalidades
        - Enviar el evento de mouseover

    Cada Frame tendrá insertado una tabla llamada HideUI y su interior será una instancia de este template,
    Para aquellos frames que puedan contener funcionalidades únicas y propias tendrán su propio módulo que heredará de la plantilla FrameTemplate
]]