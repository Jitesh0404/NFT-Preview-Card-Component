
#!/usr/bin/env bash
set -euo pipefail

PORT="8000"
URL="http://localhost:${PORT}/"

if ! curl -fsS "$URL" >/tmp/crio_card_index.html 2>/dev/null; then
  if ! ss -lnt | grep -q ":${PORT} "; then
    if ! python3 -m http.server "$PORT" >/tmp/crio_card_server.log 2>&1 & then
      echo "Failed to start local web server."
      exit 1
    fi
  fi
fi

for _ in $(seq 1 20); do
  if curl -fsS "$URL" >/tmp/crio_card_index.html 2>/dev/null; then
    break
  fi
  sleep 0.25
done

if ! curl -fsS "$URL" >/tmp/crio_card_index.html 2>/dev/null; then
  echo "Assessment failed: local server did not respond on ${URL}."
  exit 1
fi

required_strings=(
  "Equilibrium #3429"
  "Our Equilibrium collection promotes balance and calm."
  "0.041 ETH"
  "3 days left"
  "Creation of"
  "https://www.crio.do"
  "https://github.com/ketanmakode"
  "card__images-layer"
  "card__title"
)

for token in "${required_strings[@]}"; do
  if ! grep -Fq "$token" /tmp/crio_card_index.html; then
    echo "Assessment failed: missing expected content: $token"
    exit 1
  fi
done

echo "TEST_STATUS_SUCCESS"
exit 0
