import type { Metadata } from "next";
import "./globals.css";
import { PageViewTracker } from "@/components/public/page-view-tracker";

export const metadata: Metadata = {
  title: {
    default: "30Nice Growth OS",
    template: "%s | 30Nice Growth OS",
  },
  description:
    "Multi-tenant CMS, SEO AI, Analytics, Ads, Leads, and Automation platform by 30Nice.",
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="vi" className="h-full antialiased">
      <body className="min-h-full">
        <PageViewTracker />
        {children}
      </body>
    </html>
  );
}
