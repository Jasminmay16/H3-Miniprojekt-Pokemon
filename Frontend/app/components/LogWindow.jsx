import { useState, useEffect } from "react";
import LogMessage from "./LogMessage";

const API_URL = "https://h3-silvermagicians-backend.mercantec.tech/api/pokemon/log";

export default function LogWindow() {
    const [logs, setLogs] = useState(null);
    const [error, setError] = useState(null);


    useEffect(() => {
    // Aborting on cleanup stops a slow response from overwriting a newer one.
    const controller = new AbortController();

    fetch(API_URL, { signal: controller.signal })
        .then((res) => {
        if (!res.ok) {
            throw new Error(`Request failed with status ${res.status}`);
        }
        return res.json();
        })
        .then((data) => {
        setLogs(data);
        setError(null);
        })
        .catch((error) => {
        if (error.name === "AbortError") return;
        console.error("Error fetching Pokemon:", error);
        setError(error);
        });

    return () => controller.abort();
    }, []);


    if (error) {
    return <p>Error fetching Pokemon: {error.message}</p>;
    }

    if (!logs) {
    return <p>Loading...</p>;
    }
    
    return (
        <div className="log-window">
            {logs.map((log) => (
                <LogMessage key={log.id} log={log} />
            ))}
        </div>
    )
}