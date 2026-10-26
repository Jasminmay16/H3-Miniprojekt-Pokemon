import { NavLink } from "react-router";

export default function Navigation() {
    return (
        <nav className="navigation">
            <ul>
                <li><NavLink to="/">Pokemon</NavLink></li>
                <li><NavLink to="/logs">Logs</NavLink></li>
                
            </ul>
        </nav>
    );
}