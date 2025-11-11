# Scripts 폴더

이 폴더에는 로컬 개발용 스크립트가 포함됩니다.

## 설정 방법

### 1. 개발 스크립트 생성
```bash
# Windows
copy run_dev.bat.example run_dev.bat

# Mac/Linux
cp run_dev.sh.example run_dev.sh
chmod +x run_dev.sh
```

### 2. 실제 키 입력
`run_dev.bat` (또는 `run_dev.sh`)를 열고 다음 값을 입력:

```
SUPABASE_URL=https://ufbajyakzsrumrnehthq.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi... (실제 키 입력)
SENTRY_DSN=https://... (선택)
```

### 3. 실행
```bash
# Windows
scripts\run_dev.bat

# Mac/Linux
./scripts/run_dev.sh
```

## ⚠️ 보안 주의사항

- `run_dev.bat` 및 `run_dev.sh` 파일은 `.gitignore`에 포함되어 있습니다
- 이 파일들을 절대 Git에 커밋하지 마세요
- `.example` 파일만 Git에 커밋됩니다
