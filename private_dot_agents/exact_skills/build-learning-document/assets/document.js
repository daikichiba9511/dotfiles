(() => {
  "use strict";

  const exportButton = document.querySelector("[data-export-answers]");
  if (!(exportButton instanceof HTMLButtonElement)) {
    throw new Error("回答出力ボタンが見つかりません。");
  }

  exportButton.addEventListener("click", () => {
    const documentRoot = document.querySelector("[data-document-id]");
    if (!(documentRoot instanceof HTMLElement)) {
      throw new Error("文書識別子が見つかりません。");
    }

    const answers = Array.from(document.querySelectorAll("[data-check-id]")).map((element) => {
      if (!(element instanceof HTMLTextAreaElement)) {
        throw new Error("回答欄の形式が正しくありません。");
      }

      return {
        check_id: element.dataset.checkId,
        answer: element.value,
      };
    });

    const payload = {
      schema_version: 1,
      document_id: documentRoot.dataset.documentId,
      answered_at: new Date().toISOString(),
      answers,
    };

    const blob = new Blob([JSON.stringify(payload, null, 2)], {
      type: "application/json",
    });
    const downloadUrl = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = downloadUrl;
    link.download = `${documentRoot.dataset.documentId}-answers.json`;
    link.click();
    URL.revokeObjectURL(downloadUrl);
  });
})();
