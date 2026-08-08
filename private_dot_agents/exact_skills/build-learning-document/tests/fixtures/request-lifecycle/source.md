# リクエストの流れ

<!-- concept:request -->

## リクエスト

**リクエスト**とは、利用者がサーバーへ処理を求める通信を指す。

<!-- concept:response -->

## レスポンス

**レスポンス**とは、サーバーがリクエストの処理結果を返す通信を指す。

{{diagram:request-flow}}

応答時間を次の式で表す。

$$
t_{response} = t_{server} + t_{network}
$$

記号の t は時間を表す。

```typescript
const response = await fetch("/items");
console.log(response.status);
```
