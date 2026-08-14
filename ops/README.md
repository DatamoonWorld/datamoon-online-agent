# Operacao Da VM

Esta pasta contem somente artefatos instalaveis ou executaveis da operacao. O
procedimento humano completo pertence a `../docs/OPERATIONS.md`.

## Deploy

- `update_vm.sh`: atualiza os repositorios, executa gates, compila quando
  necessario, instala releases, reinicia servicos e restaura o release anterior
  em falha.
- `systemd/datamoon-deploy.service`: unit oneshot que executa o deploy
  coordenado por `/usr/local/sbin/datamoon-update`.
- `check_catalog_sync.cjs`: compara semanticamente itens do Server e da MySQL
  API, ignorando apenas campos de apresentacao.

## Instalacao

- `install_vm_connection.sh`: instala configuracoes Nginx, systemd, journald,
  fail2ban e o comando de deploy na VM.
- `install_vm_security.sh`: reaplica isoladamente os controles locais de
  seguranca e bloqueio de abuso.
- `generate_vm_secrets.sh`: gera segredos iniciais fortes para o bootstrap; nao
  imprime nem versiona valores reais.

## Ambientes

Arquivos em `env/` sao contratos sem segredo para cada servico:

- `datamoon-api.env.example`: banco, tokens internos, catalogo e API.
- `datamoon-auth.env.example`: listener e credencial interna do Auth.
- `datamoon-gateway.env.example`: WSS, versao, Auth e selecao de worker.
- `datamoon-server.env.example`: worker, rede, API, logs e regras operacionais.
- `datamoon-web.env.example`: portal, e-mail, sessao, suporte e manutencao.

Valores reais vivem em `/opt/datamoon/env` na VM e nunca entram no Git.

## Nginx

- `nginx/datamoon-gateway.conf`: virtual host e proxy WebSocket do Gateway.
- `nginx/datamoon-gateway-limits.conf`: zonas e limites de entrada do Gateway.
- `nginx/datamoon-web.conf`: virtual host HTTPS do site.
- `nginx/datamoon-web-proxy.conf`: headers e proxy para o processo Web local.
- `nginx/datamoon-web-limits.conf`: rate limits dos endpoints publicos.

## Systemd E Logs

- `systemd/datamoon-api.service`: MySQL API.
- `systemd/datamoon-auth.service`: Auth.
- `systemd/datamoon-gateway.service`: Gateway.
- `systemd/datamoon-mailer.service`: worker de e-mail transacional.
- `systemd/datamoon-web.service`: portal Web.
- `systemd/journald-datamoon.conf`: journal comprimido, limitado a 200 MB e
  retido por ate sete dias.

As instancias do Game Server sao instaladas pelo fluxo de deploy a partir do
repositorio proprietario, pois usam unit template e configuracao por worker.

## Fail2ban

- `fail2ban/filter.d/datamoon-nginx-rate-limit.conf`: reconhece rejeicoes do
  rate limit no log do Nginx.
- `fail2ban/jail.d/datamoon-web.local`: define janela, limite e banimento do
  portal.

Nao duplicar arquivos instalados fora desta estrutura. Toda adicao precisa ter
consumidor no instalador ou no deploy e ser descrita aqui.
