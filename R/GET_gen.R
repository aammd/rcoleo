#' Fonction générique pour retirer de l'information depuis l'API de Coléo
#'
#' @param endpoint `character` désignant le point d'entrée pour le retrait des données. Un point d'entrée peut être vu comme une table de la base de données.
#' @param query `list` de paramètres à passer avec l'appel sur le endpoint.
#' @param flatten `logical` aplatir automatiquement un data.frame imbriqués dans un seul `data.frame` (obsolete si l'objet retourné n'est pas un data.frame)
#' @param output `character` choix du type d'objet retourné: `data.frame`, `list`, `json`
#' @param token  `character` jeton d'accès pour authentification auprès de l'API
#' @param ... httr options; arguments de la fonction `httr::GET()`
#' @return
#' Retourne un objet de type `list` contenant les réponses de l'API. Chaque niveau de la liste correspond à une page. Pour chacun des appels sur l'API (page), la classe retourné est `getSuccess` ou `getError`. Une réponse de classe `getSuccess` est une liste à deux niveaux composé du contenu (`body`), et la réponse [httr::response]. Une réponse de classe `getError` dispose de la même structure mais ne contiendra pas de body, seulement la réponse de l'API.
#' @details
#' Les points d'accès de l'API sont énuméré dans l'environment de coléo, voir `print(endpoints)`
#' @examples
#' \dontrun{
#' resp <- get_gen("/cells")
#' length(resp) # Nombre de pages retourné par l'appel sur le point d'accès de l'API.
#' str(resp[[1]])
#' class(resp[[1]])
#' }
#' @export

get_gen <- function(endpoint, query = NULL, limit = 100, verbose = TRUE, ...) {

  url <- httr::modify_url(server(), path = paste0(base(), endpoint))
  query <- as.list(query)

  # Add number of entries to the param
  query$count <- limit

  # First call used to set pages
  # ua defined in zzz.R
  resp <- mem_get(url,
                  config = httr::add_headers(`Content-type` = "application/json"), ua,
                  query = query, ...)

  # Prep output object
  responses <- list()
  errors <- NULL

  # Get # pages
  tmp <- unlist(strsplit(httr::headers(resp)$"content-range", split = "\\D"))
  rg <- as.numeric(tmp[grepl("\\d", tmp)])
  pages <- rg[3L] %/% limit

  # Loop over pages
  for (page in 0:pages) {
    if (verbose)
      message("Data retrieval ", signif(100*(page+1)/(pages+1), 3), "%   \r",
              appendLF = FALSE)
    # cat("Data retrieval", signif(100*(page+1)/(pages+1), 3), "%   \r")
    query$page <- page
    resp <- mem_get(url,
                    config = httr::add_headers(`Content-type` = "application/json"), ua,
                    query = query, ...)

    if (httr::http_error(resp)) {
      if (verbose) msg_request_fail(resp)
      responses[[page + 1]] <- list(body = NULL, response = resp)
      errors <- append(errors, page + 1)
    } else {
      responses[[page + 1]] <- list(body = resp_raw(resp), response = resp)
    }
  }
  if (verbose) empty_line()

  if (!is.null(errors))
    warning("Failed request(s) for page(s): ", paste0(errors, ", "))

  # check error here if desired;
  out <- list(
    body = unlist(purrr::map(responses, "body"), recursive = FALSE),
    response = purrr::map(responses, "response")
  )
  # in rcoleo the class is usually set by the function that *calls* get_gen
  #class(out) <- "mgGetResponses"
  out
}



## Set memoise httr::GET
mem_get <- memoise::memoise(httr::GET)
