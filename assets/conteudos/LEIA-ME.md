Ilustrações dos conteúdos educativos (exibidas no topo da tela do módulo).

O app escolhe o arquivo pelo título do conteúdo
(lib/core/data/ilustracao_conteudo_catalog.dart):

- reciclar.jpg         -> título com "Reciclar"
- reutilizar.jpg       -> título com "Reutilizar"
- reduzir.jpg          -> título com "Reduzir"
- reparar.jpg          -> título com "Reparar"
- componentes.jpg      -> título com "Componentes"
- descarte.jpg         -> título com "Descarte"/"Descartar"
- lixo_eletronico.jpg  -> título com "Lixo eletrônico"

Sem correspondência, usa o `imagemSugerida` do backend (URL ou nome de
arquivo nesta pasta). Se o arquivo não existir, a tela mostra só o texto.
Formato: 16:9, ~1200x675, JPG.
