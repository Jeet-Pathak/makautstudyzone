import { onRequest as __api_admin_demote_js_onRequest } from "C:\\Users\\USER\\NOT YOUR BUISNESS\\functions\\api\\admin\\demote.js"
import { onRequest as __api_admin_promote_js_onRequest } from "C:\\Users\\USER\\NOT YOUR BUISNESS\\functions\\api\\admin\\promote.js"
import { onRequest as __api_pdf_proxy_js_onRequest } from "C:\\Users\\USER\\NOT YOUR BUISNESS\\functions\\api\\pdf-proxy.js"

export const routes = [
    {
      routePath: "/api/admin/demote",
      mountPath: "/api/admin",
      method: "",
      middlewares: [],
      modules: [__api_admin_demote_js_onRequest],
    },
  {
      routePath: "/api/admin/promote",
      mountPath: "/api/admin",
      method: "",
      middlewares: [],
      modules: [__api_admin_promote_js_onRequest],
    },
  {
      routePath: "/api/pdf-proxy",
      mountPath: "/api",
      method: "",
      middlewares: [],
      modules: [__api_pdf_proxy_js_onRequest],
    },
  ]