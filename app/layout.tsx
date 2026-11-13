import './globals.css';
import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'CZ AI Dashboard', description: 'ระบบบริหารงานและ AI Workspace ของ CZ Group' };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="th"><body>{children}</body></html>; }
