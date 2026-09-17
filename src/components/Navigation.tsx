import React from "react";
import {Link, useLocation} from "react-router-dom";
import {ThemeSwitchComponent} from "../providers/ThemeProvider.tsx";

export default function Navigation()
{
    const [isMenuOpen, setIsMenuOpen] = React.useState(false);
    const location = useLocation();

    const pages: Record<string, string> = {
        "Home": "/",
        "About": "/about"
    };

    return (
        <nav className="sticky top-0 z-40 w-full border-b border-separator bg-background/70 backdrop-blur-lg">
            <header className="flex h-16 items-center justify-between px-6">
                <div className="flex items-center gap-4">
                    <button
                        className="sm:hidden"
                        onClick={() => setIsMenuOpen(!isMenuOpen)}
                        aria-label={isMenuOpen ? "Close menu" : "Open menu"}
                        aria-expanded={isMenuOpen}
                    >
                        <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            {isMenuOpen ? (
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                                      d="M6 18L18 6M6 6l12 12"/>
                            ) : (
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                                      d="M4 6h16M4 12h16M4 18h16"/>
                            )}
                        </svg>
                    </button>
                    <p className="font-bold text-foreground">tavern php template</p>
                </div>
                <ul className="hidden sm:flex items-center gap-4">
                    {Object.entries(pages).map(([label, url]) => (
                        <li key={url}>
                            <Link
                                to={url}
                                className={location.pathname === url
                                    ? "text-accent font-medium"
                                    : "text-foreground hover:text-accent transition-colors"}
                                aria-current={location.pathname === url ? "page" : undefined}
                            >
                                {label}
                            </Link>
                        </li>
                    ))}
                </ul>
                <div className="flex items-center gap-2">
                    <ThemeSwitchComponent/>
                </div>
            </header>
            {isMenuOpen && (
                <div className="border-t border-separator sm:hidden">
                    <ul className="flex flex-col gap-2 p-4">
                        {Object.entries(pages).map(([label, url]) => (
                            <li key={url}>
                                <Link
                                    to={url}
                                    className={`block py-2 ${location.pathname === url
                                        ? "text-accent font-medium"
                                        : "text-foreground hover:text-accent transition-colors"}`}
                                    aria-current={location.pathname === url ? "page" : undefined}
                                    onClick={() => setIsMenuOpen(false)}
                                >
                                    {label}
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>
            )}
        </nav>
    );
}
