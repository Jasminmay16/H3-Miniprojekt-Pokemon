export default function LogMessage({ log }) {
    return <div className="log-message">
        <span className="log-message-timestamp">{log.createdAt}</span>
        <span className="log-message-action">{log.action}</span>

    </div>;
}