
from fastapi import FastAPI

app = FastAPI(
    title="MyFinance API",
    description="API para gerenciamento financeiro pessoal",
    version="1.0.0"
)


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "message": "MyFinance API is running"
    }
