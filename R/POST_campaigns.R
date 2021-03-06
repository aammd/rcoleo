#' Publication d'une campagne sur la base de données de Coléo
#'
#' Cette fonction applique la méthode POST sur le point d'entrées `campaigns` de l'API de Coleo
#'
#' @inheritParams post_cells
#' @export

post_campaigns <- function(data, ...) {

  # Preparation de l'objet de sortie
  responses <- list()
  class(responses) <- "coleoPostResp"

  endpoint <- endpoints()$campaigns

  for (i in 1:length(data)) {
    # On retourne l'id unique de la table sites
    # Le unlist c'est pour les pages, mais je sais que la réponse contient une seule page (match sur un code)
    data[[i]]$site_id <- as.data.frame(get_sites(site_code=data[[i]]$site_code))$id
    responses[[i]] <- post_gen(endpoint, data[[i]], ...)
  }

  return(responses)
}
