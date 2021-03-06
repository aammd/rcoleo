#' Publication d'un site sur la base de données de Coléo
#'
#' Cette fonction applique la méthode POST sur le point d'entrées `sites` de l'API de Coleo
#'
#' @inheritParams post_cells
#' @export

post_sites <- function(data, ...) {

  # Preparation de l'objet de sortie
  responses <- list()
  class(responses) <- "coleoPostResp"

  endpoint <- endpoints()$sites

  for (i in 1:length(data)) {
    # On retourne l'id unique de la table cell
    # Le unlist c'est pour les pages, mais je sais que la réponse contient une seule page (match sur un code)
    data[[i]]$cell_id <- as.data.frame(get_cells(data[[i]]$cell_id))$id
    responses[[i]] <- post_gen(endpoint, data[[i]], ...)
  }

  return(responses)
}
