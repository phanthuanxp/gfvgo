-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('SUPER_ADMIN', 'AGENCY_ADMIN', 'TENANT_ADMIN', 'EDITOR', 'VIEWER');

-- CreateEnum
CREATE TYPE "TenantStatus" AS ENUM ('ACTIVE', 'PAUSED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "ContentStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "SocialPlatform" AS ENUM ('FACEBOOK');

-- CreateEnum
CREATE TYPE "SocialWorkspaceStatus" AS ENUM ('DRAFT', 'ACTIVE', 'PAUSED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "SocialPageStatus" AS ENUM ('PLANNING', 'SETUP', 'CONNECTED', 'PAUSED', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "SocialPlanStatus" AS ENUM ('DRAFT', 'ACTIVE', 'PAUSED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "SocialContentStatus" AS ENUM ('IDEA', 'DRAFT', 'IN_REVIEW', 'APPROVED', 'SCHEDULED', 'PUBLISHED', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "SocialPublishTargetType" AS ENUM ('PAGE', 'GROUP');

-- CreateEnum
CREATE TYPE "SocialPublishStatus" AS ENUM ('DRAFT', 'PENDING_APPROVAL', 'SCHEDULED', 'PUBLISHED', 'MANUAL_REQUIRED', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "SocialGroupMode" AS ENUM ('MANUAL_ONLY', 'API_ALLOWED', 'DISABLED');

-- CreateEnum
CREATE TYPE "SocialGroupStatus" AS ENUM ('CANDIDATE', 'APPROVED', 'PAUSED', 'REJECTED');

-- CreateEnum
CREATE TYPE "SeoIntent" AS ENUM ('INFORMATIONAL', 'COMMERCIAL', 'TRANSACTIONAL', 'NAVIGATIONAL', 'UNKNOWN');

-- CreateEnum
CREATE TYPE "KeywordProjectStatus" AS ENUM ('DRAFT', 'ACTIVE', 'ARCHIVED');

-- CreateEnum
CREATE TYPE "SubdomainPlanStatus" AS ENUM ('DRAFT', 'APPROVED', 'CREATED', 'REJECTED');

-- CreateEnum
CREATE TYPE "ContentPlanStatus" AS ENUM ('DRAFT', 'ACTIVE', 'PAUSED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "ContentPlanItemStatus" AS ENUM ('PLANNED', 'DRAFTING', 'DRAFT', 'SCHEDULED', 'PUBLISHED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "ContentSourceType" AS ENUM ('WEBSITE', 'SITEMAP', 'RSS', 'MANUAL_URL_LIST');

-- CreateEnum
CREATE TYPE "CrawlStatus" AS ENUM ('PENDING', 'RUNNING', 'COMPLETED', 'FAILED', 'SKIPPED');

-- CreateEnum
CREATE TYPE "SourceArticleStatus" AS ENUM ('DISCOVERED', 'EXTRACTED', 'READY_FOR_REWRITE', 'REWRITE_QUEUED', 'DRAFT_CREATED', 'SCHEDULED', 'PUBLISHED', 'DUPLICATE', 'FAILED');

-- CreateEnum
CREATE TYPE "AiContentJobStatus" AS ENUM ('PENDING', 'BRIEF_READY', 'GENERATING', 'DRAFT', 'REVIEW', 'PUBLISHED', 'FAILED');

-- CreateEnum
CREATE TYPE "AiContentType" AS ENUM ('BLOG_POST', 'LANDING_PAGE', 'SERVICE_PAGE', 'FAQ_PAGE', 'REVIEW_PAGE', 'COMPARISON_PAGE');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "passwordHash" TEXT,
    "role" "Role" NOT NULL DEFAULT 'VIEWER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Organization" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Organization_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "OrganizationMember" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'AGENCY_ADMIN',

    CONSTRAINT "OrganizationMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Tenant" (
    "id" TEXT NOT NULL,
    "organizationId" TEXT,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "primaryDomain" TEXT,
    "status" "TenantStatus" NOT NULL DEFAULT 'ACTIVE',
    "logoUrl" TEXT,
    "brandPrimary" TEXT DEFAULT '#10b981',
    "brandSecondary" TEXT DEFAULT '#0ea5e9',
    "businessName" TEXT,
    "businessPhone" TEXT,
    "businessEmail" TEXT,
    "businessAddress" TEXT,
    "defaultSeoTitle" TEXT,
    "defaultSeoDescription" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Tenant_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TenantMember" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'EDITOR',

    CONSTRAINT "TenantMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SiteSettings" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "logoUrl" TEXT,
    "faviconUrl" TEXT,
    "primaryColor" TEXT DEFAULT '#10b981',
    "secondaryColor" TEXT DEFAULT '#0ea5e9',
    "phone" TEXT,
    "email" TEXT,
    "address" TEXT,
    "socialLinks" JSONB,
    "defaultSeoTitle" TEXT,
    "defaultSeoDescription" TEXT,
    "theme" TEXT DEFAULT 'default',
    "themeConfig" JSONB,

    CONSTRAINT "SiteSettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Domain" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "host" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "primary" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Domain_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Page" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "status" "ContentStatus" NOT NULL DEFAULT 'DRAFT',
    "summary" TEXT,
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "ogImageUrl" TEXT,
    "uiBlocks" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Page_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PageRevision" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "pageId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "status" "ContentStatus" NOT NULL,
    "summary" TEXT,
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "ogImageUrl" TEXT,
    "uiBlocks" JSONB NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PageRevision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Category" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Category_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Post" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "categoryId" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "excerpt" TEXT,
    "content" TEXT NOT NULL,
    "featuredImage" TEXT,
    "status" "ContentStatus" NOT NULL DEFAULT 'DRAFT',
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "ogTitle" TEXT,
    "ogDescription" TEXT,
    "ogImage" TEXT,
    "twitterCard" TEXT,
    "schemaType" TEXT,
    "schemaData" TEXT,
    "robotsMeta" TEXT,
    "canonicalUrl" TEXT,
    "qualityScore" INTEGER,
    "seoScore" INTEGER,
    "qualityReport" JSONB,
    "publishedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Post_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PostRevision" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "postId" TEXT NOT NULL,
    "categoryId" TEXT,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "excerpt" TEXT,
    "content" TEXT NOT NULL,
    "featuredImage" TEXT,
    "status" "ContentStatus" NOT NULL,
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "ogTitle" TEXT,
    "ogDescription" TEXT,
    "ogImage" TEXT,
    "twitterCard" TEXT,
    "schemaType" TEXT,
    "schemaData" TEXT,
    "robotsMeta" TEXT,
    "canonicalUrl" TEXT,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PostRevision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MediaAsset" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "alt" TEXT,
    "filename" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MediaAsset_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Menu" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Menu_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MenuItem" (
    "id" TEXT NOT NULL,
    "menuId" TEXT NOT NULL,
    "parentId" TEXT,
    "label" TEXT NOT NULL,
    "href" TEXT NOT NULL,
    "order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "MenuItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Form" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "fields" JSONB NOT NULL,
    "settings" JSONB,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Form_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FormSubmission" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "formId" TEXT,
    "leadId" TEXT,
    "payload" JSONB NOT NULL,
    "sourcePath" TEXT,
    "sourceDomain" TEXT,
    "userAgent" TEXT,
    "ipHash" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "FormSubmission_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RedirectRule" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "fromPath" TEXT NOT NULL,
    "toPath" TEXT NOT NULL,
    "statusCode" INTEGER NOT NULL DEFAULT 301,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RedirectRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiUsageLog" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "feature" TEXT NOT NULL,
    "tokens" INTEGER NOT NULL DEFAULT 0,
    "cost" DECIMAL(10,4),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiUsageLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SeoAudit" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "score" INTEGER NOT NULL,
    "issues" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SeoAudit_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Integration" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'DISCONNECTED',
    "config" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Integration_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AutomationJob" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "payload" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AutomationJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialWorkspace" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "status" "SocialWorkspaceStatus" NOT NULL DEFAULT 'DRAFT',
    "objective" TEXT,
    "locale" TEXT NOT NULL DEFAULT 'vi-VN',
    "timezone" TEXT NOT NULL DEFAULT 'Asia/Bangkok',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialWorkspace_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialPage" (
    "id" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "platform" "SocialPlatform" NOT NULL DEFAULT 'FACEBOOK',
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "externalPageId" TEXT,
    "pageUrl" TEXT,
    "status" "SocialPageStatus" NOT NULL DEFAULT 'PLANNING',
    "category" TEXT,
    "objective" TEXT,
    "targetAudience" JSONB,
    "brandVoice" JSONB,
    "contentPillars" JSONB,
    "postingRules" JSONB,
    "launchKit" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialPage_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialConnection" (
    "id" TEXT NOT NULL,
    "socialPageId" TEXT NOT NULL,
    "encryptedToken" TEXT NOT NULL,
    "tokenExpiresAt" TIMESTAMP(3),
    "grantedScopes" TEXT[],
    "connectionStatus" TEXT NOT NULL DEFAULT 'CONNECTED',
    "lastValidatedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialConnection_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialContentPlan" (
    "id" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "socialPageId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "objective" TEXT,
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "status" "SocialPlanStatus" NOT NULL DEFAULT 'DRAFT',
    "strategy" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialContentPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialContent" (
    "id" TEXT NOT NULL,
    "planId" TEXT,
    "socialPageId" TEXT NOT NULL,
    "topic" TEXT NOT NULL,
    "pillar" TEXT,
    "format" TEXT NOT NULL DEFAULT 'POST',
    "title" TEXT,
    "hook" TEXT,
    "caption" TEXT,
    "callToAction" TEXT,
    "hashtags" TEXT[],
    "mediaBrief" JSONB,
    "status" "SocialContentStatus" NOT NULL DEFAULT 'IDEA',
    "scheduledAt" TIMESTAMP(3),
    "approvedAt" TIMESTAMP(3),
    "approvedById" TEXT,
    "sourcePostId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialContent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialContentRevision" (
    "id" TEXT NOT NULL,
    "socialContentId" TEXT NOT NULL,
    "version" INTEGER NOT NULL,
    "snapshot" JSONB NOT NULL,
    "changeNote" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SocialContentRevision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialGroup" (
    "id" TEXT NOT NULL,
    "workspaceId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "groupUrl" TEXT,
    "externalGroupId" TEXT,
    "status" "SocialGroupStatus" NOT NULL DEFAULT 'CANDIDATE',
    "mode" "SocialGroupMode" NOT NULL DEFAULT 'MANUAL_ONLY',
    "topics" TEXT[],
    "rules" JSONB,
    "dailyPostLimit" INTEGER NOT NULL DEFAULT 1,
    "cooldownHours" INTEGER NOT NULL DEFAULT 24,
    "allowLinks" BOOLEAN NOT NULL DEFAULT true,
    "allowPromotion" BOOLEAN NOT NULL DEFAULT true,
    "apiVerifiedAt" TIMESTAMP(3),
    "approvedAt" TIMESTAMP(3),
    "approvedById" TEXT,
    "statusReason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialGroup_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialPublishTarget" (
    "id" TEXT NOT NULL,
    "socialContentId" TEXT NOT NULL,
    "socialPageId" TEXT NOT NULL,
    "socialGroupId" TEXT,
    "targetType" "SocialPublishTargetType" NOT NULL,
    "captionOverride" TEXT,
    "scheduledAt" TIMESTAMP(3),
    "publishedAt" TIMESTAMP(3),
    "externalPostId" TEXT,
    "status" "SocialPublishStatus" NOT NULL DEFAULT 'DRAFT',
    "errorMessage" TEXT,
    "idempotencyKey" TEXT NOT NULL,
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "maxAttempts" INTEGER NOT NULL DEFAULT 3,
    "lastAttemptAt" TIMESTAMP(3),
    "nextAttemptAt" TIMESTAMP(3),
    "lockedAt" TIMESTAMP(3),
    "lockToken" TEXT,
    "permanentFailure" BOOLEAN NOT NULL DEFAULT false,
    "externalPostUrl" TEXT,
    "responseMetadata" JSONB,
    "manualPostedById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialPublishTarget_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MetaOAuthSession" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "socialPageId" TEXT NOT NULL,
    "availablePages" JSONB NOT NULL,
    "encryptedPageTokens" JSONB NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "consumedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "MetaOAuthSession_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialPostInsight" (
    "id" TEXT NOT NULL,
    "publishTargetId" TEXT NOT NULL,
    "views" INTEGER NOT NULL DEFAULT 0,
    "reach" INTEGER NOT NULL DEFAULT 0,
    "engagements" INTEGER NOT NULL DEFAULT 0,
    "reactions" INTEGER NOT NULL DEFAULT 0,
    "comments" INTEGER NOT NULL DEFAULT 0,
    "shares" INTEGER NOT NULL DEFAULT 0,
    "rawMetrics" JSONB,
    "capturedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialPostInsight_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialWebhookEvent" (
    "id" TEXT NOT NULL,
    "eventHash" TEXT NOT NULL,
    "externalPageId" TEXT,
    "field" TEXT,
    "payload" JSONB NOT NULL,
    "processedAt" TIMESTAMP(3),
    "attempts" INTEGER NOT NULL DEFAULT 0,
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SocialWebhookEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SocialComment" (
    "id" TEXT NOT NULL,
    "externalCommentId" TEXT NOT NULL,
    "externalPostId" TEXT NOT NULL,
    "publishTargetId" TEXT,
    "socialPageId" TEXT,
    "parentCommentId" TEXT,
    "authorId" TEXT,
    "authorName" TEXT,
    "message" TEXT,
    "isFromPage" BOOLEAN NOT NULL DEFAULT false,
    "postedAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SocialComment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiProviderConfig" (
    "id" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "label" TEXT NOT NULL,
    "apiKey" TEXT,
    "baseUrl" TEXT,
    "model" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT false,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "isFallback" BOOLEAN NOT NULL DEFAULT false,
    "priority" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiProviderConfig_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AnalyticsEvent" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'pageview',
    "path" TEXT NOT NULL,
    "referrer" TEXT,
    "device" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AnalyticsEvent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "tenantId" TEXT,
    "action" TEXT NOT NULL,
    "resource" TEXT,
    "resourceId" TEXT,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KeywordProject" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "niche" TEXT,
    "description" TEXT,
    "language" TEXT NOT NULL DEFAULT 'vi',
    "country" TEXT NOT NULL DEFAULT 'VN',
    "status" "KeywordProjectStatus" NOT NULL DEFAULT 'DRAFT',
    "ownerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "KeywordProject_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Keyword" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "text" TEXT NOT NULL,
    "normalizedText" TEXT NOT NULL,
    "searchVolume" INTEGER,
    "difficulty" INTEGER,
    "cpc" DECIMAL(10,2),
    "competition" DOUBLE PRECISION,
    "intent" "SeoIntent" NOT NULL DEFAULT 'UNKNOWN',
    "language" TEXT NOT NULL DEFAULT 'vi',
    "country" TEXT NOT NULL DEFAULT 'VN',
    "source" TEXT,
    "embedding" JSONB,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Keyword_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KeywordCluster" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "headKeyword" TEXT,
    "intent" "SeoIntent" NOT NULL DEFAULT 'UNKNOWN',
    "totalVolume" INTEGER NOT NULL DEFAULT 0,
    "avgDifficulty" INTEGER,
    "suggestedSlug" TEXT,
    "suggestedDomain" TEXT,
    "assignedTenantId" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "KeywordCluster_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KeywordClusterMember" (
    "id" TEXT NOT NULL,
    "clusterId" TEXT NOT NULL,
    "keywordId" TEXT NOT NULL,
    "isPrimary" BOOLEAN NOT NULL DEFAULT false,
    "similarity" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "KeywordClusterMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SubdomainPlan" (
    "id" TEXT NOT NULL,
    "rootDomain" TEXT NOT NULL,
    "subdomain" TEXT NOT NULL,
    "fullDomain" TEXT NOT NULL,
    "keyword" TEXT NOT NULL,
    "niche" TEXT,
    "location" TEXT,
    "intent" TEXT,
    "language" TEXT NOT NULL DEFAULT 'en',
    "seoScore" INTEGER NOT NULL DEFAULT 0,
    "opportunityScore" INTEGER NOT NULL DEFAULT 0,
    "rationale" TEXT,
    "status" "SubdomainPlanStatus" NOT NULL DEFAULT 'DRAFT',
    "keywordProjectId" TEXT,
    "tenantId" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SubdomainPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContentPlan" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT,
    "subdomainPlanId" TEXT,
    "title" TEXT NOT NULL,
    "goal" TEXT,
    "language" TEXT NOT NULL DEFAULT 'en',
    "status" "ContentPlanStatus" NOT NULL DEFAULT 'DRAFT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContentPlan_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContentPlanItem" (
    "id" TEXT NOT NULL,
    "contentPlanId" TEXT NOT NULL,
    "keyword" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "intent" TEXT,
    "articleType" TEXT NOT NULL DEFAULT 'travel_guide',
    "priority" INTEGER NOT NULL DEFAULT 50,
    "status" "ContentPlanItemStatus" NOT NULL DEFAULT 'PLANNED',
    "scheduledAt" TIMESTAMP(3),
    "postId" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContentPlanItem_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ContentSource" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT,
    "name" TEXT NOT NULL,
    "baseUrl" TEXT NOT NULL,
    "sourceType" "ContentSourceType" NOT NULL DEFAULT 'WEBSITE',
    "language" TEXT NOT NULL DEFAULT 'en',
    "niche" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "crawlStatus" "CrawlStatus" NOT NULL DEFAULT 'PENDING',
    "lastCrawledAt" TIMESTAMP(3),
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ContentSource_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SourceArticle" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT,
    "sourceId" TEXT,
    "url" TEXT NOT NULL,
    "title" TEXT,
    "canonicalUrl" TEXT,
    "rawHtml" TEXT,
    "extractedText" TEXT,
    "excerpt" TEXT,
    "author" TEXT,
    "publishedAt" TIMESTAMP(3),
    "imageUrl" TEXT,
    "contentHash" TEXT,
    "language" TEXT NOT NULL DEFAULT 'en',
    "status" "SourceArticleStatus" NOT NULL DEFAULT 'DISCOVERED',
    "targetKeyword" TEXT,
    "subdomainPlanId" TEXT,
    "draftPostId" TEXT,
    "contentPlanItemId" TEXT,
    "scheduledPublishAt" TIMESTAMP(3),
    "reviewedAt" TIMESTAMP(3),
    "reviewedById" TEXT,
    "metadata" JSONB,
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "SourceArticle_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CrawlJob" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT,
    "sourceId" TEXT,
    "status" "CrawlStatus" NOT NULL DEFAULT 'PENDING',
    "input" JSONB,
    "discovered" INTEGER NOT NULL DEFAULT 0,
    "extracted" INTEGER NOT NULL DEFAULT 0,
    "failed" INTEGER NOT NULL DEFAULT 0,
    "errorMessage" TEXT,
    "startedAt" TIMESTAMP(3),
    "finishedAt" TIMESTAMP(3),
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CrawlJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiContentJob" (
    "id" TEXT NOT NULL,
    "tenantId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "targetKeyword" TEXT,
    "keywords" TEXT[],
    "contentType" "AiContentType" NOT NULL DEFAULT 'BLOG_POST',
    "targetLength" INTEGER NOT NULL DEFAULT 1000,
    "language" TEXT NOT NULL DEFAULT 'vi',
    "status" "AiContentJobStatus" NOT NULL DEFAULT 'PENDING',
    "brief" JSONB,
    "draftHtml" TEXT,
    "draftText" TEXT,
    "seoTitle" TEXT,
    "seoDescription" TEXT,
    "pageId" TEXT,
    "postId" TEXT,
    "errorMessage" TEXT,
    "createdById" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AiContentJob_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Organization_slug_key" ON "Organization"("slug");

-- CreateIndex
CREATE INDEX "OrganizationMember_userId_idx" ON "OrganizationMember"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "OrganizationMember_organizationId_userId_key" ON "OrganizationMember"("organizationId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "Tenant_slug_key" ON "Tenant"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Tenant_primaryDomain_key" ON "Tenant"("primaryDomain");

-- CreateIndex
CREATE INDEX "Tenant_status_idx" ON "Tenant"("status");

-- CreateIndex
CREATE INDEX "TenantMember_userId_idx" ON "TenantMember"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "TenantMember_tenantId_userId_key" ON "TenantMember"("tenantId", "userId");

-- CreateIndex
CREATE UNIQUE INDEX "SiteSettings_tenantId_key" ON "SiteSettings"("tenantId");

-- CreateIndex
CREATE UNIQUE INDEX "Domain_host_key" ON "Domain"("host");

-- CreateIndex
CREATE INDEX "Domain_tenantId_idx" ON "Domain"("tenantId");

-- CreateIndex
CREATE INDEX "Page_tenantId_status_idx" ON "Page"("tenantId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Page_tenantId_slug_key" ON "Page"("tenantId", "slug");

-- CreateIndex
CREATE INDEX "PageRevision_tenantId_pageId_idx" ON "PageRevision"("tenantId", "pageId");

-- CreateIndex
CREATE INDEX "PageRevision_pageId_version_idx" ON "PageRevision"("pageId", "version");

-- CreateIndex
CREATE INDEX "Category_tenantId_idx" ON "Category"("tenantId");

-- CreateIndex
CREATE UNIQUE INDEX "Category_tenantId_slug_key" ON "Category"("tenantId", "slug");

-- CreateIndex
CREATE INDEX "Post_tenantId_status_idx" ON "Post"("tenantId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "Post_tenantId_slug_key" ON "Post"("tenantId", "slug");

-- CreateIndex
CREATE INDEX "PostRevision_tenantId_postId_idx" ON "PostRevision"("tenantId", "postId");

-- CreateIndex
CREATE INDEX "PostRevision_postId_version_idx" ON "PostRevision"("postId", "version");

-- CreateIndex
CREATE INDEX "MediaAsset_tenantId_idx" ON "MediaAsset"("tenantId");

-- CreateIndex
CREATE INDEX "Menu_tenantId_idx" ON "Menu"("tenantId");

-- CreateIndex
CREATE INDEX "MenuItem_menuId_idx" ON "MenuItem"("menuId");

-- CreateIndex
CREATE INDEX "Form_tenantId_active_idx" ON "Form"("tenantId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "Form_tenantId_slug_key" ON "Form"("tenantId", "slug");

-- CreateIndex
CREATE INDEX "FormSubmission_tenantId_createdAt_idx" ON "FormSubmission"("tenantId", "createdAt");

-- CreateIndex
CREATE INDEX "FormSubmission_formId_idx" ON "FormSubmission"("formId");

-- CreateIndex
CREATE INDEX "FormSubmission_leadId_idx" ON "FormSubmission"("leadId");

-- CreateIndex
CREATE INDEX "RedirectRule_tenantId_active_idx" ON "RedirectRule"("tenantId", "active");

-- CreateIndex
CREATE UNIQUE INDEX "RedirectRule_tenantId_fromPath_key" ON "RedirectRule"("tenantId", "fromPath");

-- CreateIndex
CREATE INDEX "AiUsageLog_tenantId_idx" ON "AiUsageLog"("tenantId");

-- CreateIndex
CREATE INDEX "SeoAudit_tenantId_idx" ON "SeoAudit"("tenantId");

-- CreateIndex
CREATE INDEX "Integration_tenantId_provider_idx" ON "Integration"("tenantId", "provider");

-- CreateIndex
CREATE INDEX "AutomationJob_tenantId_status_idx" ON "AutomationJob"("tenantId", "status");

-- CreateIndex
CREATE INDEX "SocialWorkspace_tenantId_status_idx" ON "SocialWorkspace"("tenantId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SocialWorkspace_tenantId_slug_key" ON "SocialWorkspace"("tenantId", "slug");

-- CreateIndex
CREATE INDEX "SocialPage_workspaceId_status_idx" ON "SocialPage"("workspaceId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SocialPage_workspaceId_slug_key" ON "SocialPage"("workspaceId", "slug");

-- CreateIndex
CREATE UNIQUE INDEX "SocialPage_platform_externalPageId_key" ON "SocialPage"("platform", "externalPageId");

-- CreateIndex
CREATE UNIQUE INDEX "SocialConnection_socialPageId_key" ON "SocialConnection"("socialPageId");

-- CreateIndex
CREATE INDEX "SocialContentPlan_workspaceId_status_idx" ON "SocialContentPlan"("workspaceId", "status");

-- CreateIndex
CREATE INDEX "SocialContentPlan_socialPageId_startDate_idx" ON "SocialContentPlan"("socialPageId", "startDate");

-- CreateIndex
CREATE INDEX "SocialContent_socialPageId_status_scheduledAt_idx" ON "SocialContent"("socialPageId", "status", "scheduledAt");

-- CreateIndex
CREATE INDEX "SocialContent_planId_idx" ON "SocialContent"("planId");

-- CreateIndex
CREATE INDEX "SocialContentRevision_socialContentId_createdAt_idx" ON "SocialContentRevision"("socialContentId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SocialContentRevision_socialContentId_version_key" ON "SocialContentRevision"("socialContentId", "version");

-- CreateIndex
CREATE INDEX "SocialGroup_workspaceId_status_idx" ON "SocialGroup"("workspaceId", "status");

-- CreateIndex
CREATE UNIQUE INDEX "SocialPublishTarget_idempotencyKey_key" ON "SocialPublishTarget"("idempotencyKey");

-- CreateIndex
CREATE INDEX "SocialPublishTarget_socialPageId_status_scheduledAt_idx" ON "SocialPublishTarget"("socialPageId", "status", "scheduledAt");

-- CreateIndex
CREATE INDEX "SocialPublishTarget_socialGroupId_status_idx" ON "SocialPublishTarget"("socialGroupId", "status");

-- CreateIndex
CREATE INDEX "SocialPublishTarget_socialGroupId_publishedAt_idx" ON "SocialPublishTarget"("socialGroupId", "publishedAt");

-- CreateIndex
CREATE INDEX "SocialPublishTarget_status_scheduledAt_nextAttemptAt_idx" ON "SocialPublishTarget"("status", "scheduledAt", "nextAttemptAt");

-- CreateIndex
CREATE INDEX "MetaOAuthSession_userId_expiresAt_idx" ON "MetaOAuthSession"("userId", "expiresAt");

-- CreateIndex
CREATE INDEX "MetaOAuthSession_socialPageId_expiresAt_idx" ON "MetaOAuthSession"("socialPageId", "expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "SocialPostInsight_publishTargetId_key" ON "SocialPostInsight"("publishTargetId");

-- CreateIndex
CREATE INDEX "SocialPostInsight_capturedAt_idx" ON "SocialPostInsight"("capturedAt");

-- CreateIndex
CREATE UNIQUE INDEX "SocialWebhookEvent_eventHash_key" ON "SocialWebhookEvent"("eventHash");

-- CreateIndex
CREATE INDEX "SocialWebhookEvent_externalPageId_createdAt_idx" ON "SocialWebhookEvent"("externalPageId", "createdAt");

-- CreateIndex
CREATE INDEX "SocialWebhookEvent_processedAt_createdAt_idx" ON "SocialWebhookEvent"("processedAt", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "SocialComment_externalCommentId_key" ON "SocialComment"("externalCommentId");

-- CreateIndex
CREATE INDEX "SocialComment_socialPageId_postedAt_idx" ON "SocialComment"("socialPageId", "postedAt");

-- CreateIndex
CREATE INDEX "SocialComment_publishTargetId_postedAt_idx" ON "SocialComment"("publishTargetId", "postedAt");

-- CreateIndex
CREATE INDEX "SocialComment_externalPostId_idx" ON "SocialComment"("externalPostId");

-- CreateIndex
CREATE UNIQUE INDEX "AiProviderConfig_provider_key" ON "AiProviderConfig"("provider");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_tenantId_createdAt_idx" ON "AnalyticsEvent"("tenantId", "createdAt");

-- CreateIndex
CREATE INDEX "AnalyticsEvent_tenantId_path_idx" ON "AnalyticsEvent"("tenantId", "path");

-- CreateIndex
CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_tenantId_createdAt_idx" ON "AuditLog"("tenantId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_action_idx" ON "AuditLog"("action");

-- CreateIndex
CREATE INDEX "KeywordProject_status_idx" ON "KeywordProject"("status");

-- CreateIndex
CREATE INDEX "KeywordProject_ownerId_idx" ON "KeywordProject"("ownerId");

-- CreateIndex
CREATE INDEX "Keyword_projectId_intent_idx" ON "Keyword"("projectId", "intent");

-- CreateIndex
CREATE INDEX "Keyword_projectId_searchVolume_idx" ON "Keyword"("projectId", "searchVolume");

-- CreateIndex
CREATE UNIQUE INDEX "Keyword_projectId_normalizedText_key" ON "Keyword"("projectId", "normalizedText");

-- CreateIndex
CREATE INDEX "KeywordCluster_projectId_idx" ON "KeywordCluster"("projectId");

-- CreateIndex
CREATE INDEX "KeywordCluster_assignedTenantId_idx" ON "KeywordCluster"("assignedTenantId");

-- CreateIndex
CREATE INDEX "KeywordClusterMember_keywordId_idx" ON "KeywordClusterMember"("keywordId");

-- CreateIndex
CREATE UNIQUE INDEX "KeywordClusterMember_clusterId_keywordId_key" ON "KeywordClusterMember"("clusterId", "keywordId");

-- CreateIndex
CREATE INDEX "SubdomainPlan_status_idx" ON "SubdomainPlan"("status");

-- CreateIndex
CREATE INDEX "SubdomainPlan_fullDomain_idx" ON "SubdomainPlan"("fullDomain");

-- CreateIndex
CREATE INDEX "SubdomainPlan_keywordProjectId_idx" ON "SubdomainPlan"("keywordProjectId");

-- CreateIndex
CREATE INDEX "SubdomainPlan_tenantId_idx" ON "SubdomainPlan"("tenantId");

-- CreateIndex
CREATE UNIQUE INDEX "SubdomainPlan_rootDomain_subdomain_key" ON "SubdomainPlan"("rootDomain", "subdomain");

-- CreateIndex
CREATE INDEX "ContentPlan_tenantId_idx" ON "ContentPlan"("tenantId");

-- CreateIndex
CREATE INDEX "ContentPlan_subdomainPlanId_idx" ON "ContentPlan"("subdomainPlanId");

-- CreateIndex
CREATE INDEX "ContentPlan_status_idx" ON "ContentPlan"("status");

-- CreateIndex
CREATE INDEX "ContentPlanItem_contentPlanId_idx" ON "ContentPlanItem"("contentPlanId");

-- CreateIndex
CREATE INDEX "ContentPlanItem_status_idx" ON "ContentPlanItem"("status");

-- CreateIndex
CREATE INDEX "ContentPlanItem_priority_idx" ON "ContentPlanItem"("priority");

-- CreateIndex
CREATE INDEX "ContentSource_tenantId_idx" ON "ContentSource"("tenantId");

-- CreateIndex
CREATE INDEX "ContentSource_sourceType_idx" ON "ContentSource"("sourceType");

-- CreateIndex
CREATE INDEX "ContentSource_crawlStatus_idx" ON "ContentSource"("crawlStatus");

-- CreateIndex
CREATE UNIQUE INDEX "ContentSource_tenantId_baseUrl_key" ON "ContentSource"("tenantId", "baseUrl");

-- CreateIndex
CREATE INDEX "SourceArticle_tenantId_idx" ON "SourceArticle"("tenantId");

-- CreateIndex
CREATE INDEX "SourceArticle_sourceId_idx" ON "SourceArticle"("sourceId");

-- CreateIndex
CREATE INDEX "SourceArticle_status_idx" ON "SourceArticle"("status");

-- CreateIndex
CREATE INDEX "SourceArticle_contentHash_idx" ON "SourceArticle"("contentHash");

-- CreateIndex
CREATE INDEX "SourceArticle_draftPostId_idx" ON "SourceArticle"("draftPostId");

-- CreateIndex
CREATE INDEX "SourceArticle_contentPlanItemId_idx" ON "SourceArticle"("contentPlanItemId");

-- CreateIndex
CREATE UNIQUE INDEX "SourceArticle_url_key" ON "SourceArticle"("url");

-- CreateIndex
CREATE INDEX "CrawlJob_tenantId_idx" ON "CrawlJob"("tenantId");

-- CreateIndex
CREATE INDEX "CrawlJob_sourceId_idx" ON "CrawlJob"("sourceId");

-- CreateIndex
CREATE INDEX "CrawlJob_status_idx" ON "CrawlJob"("status");

-- CreateIndex
CREATE INDEX "AiContentJob_tenantId_status_idx" ON "AiContentJob"("tenantId", "status");

-- CreateIndex
CREATE INDEX "AiContentJob_tenantId_createdAt_idx" ON "AiContentJob"("tenantId", "createdAt");

-- CreateIndex
CREATE INDEX "AiContentJob_createdById_idx" ON "AiContentJob"("createdById");

-- AddForeignKey
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "OrganizationMember" ADD CONSTRAINT "OrganizationMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Tenant" ADD CONSTRAINT "Tenant_organizationId_fkey" FOREIGN KEY ("organizationId") REFERENCES "Organization"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TenantMember" ADD CONSTRAINT "TenantMember_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TenantMember" ADD CONSTRAINT "TenantMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SiteSettings" ADD CONSTRAINT "SiteSettings_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Domain" ADD CONSTRAINT "Domain_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Page" ADD CONSTRAINT "Page_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PageRevision" ADD CONSTRAINT "PageRevision_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PageRevision" ADD CONSTRAINT "PageRevision_pageId_fkey" FOREIGN KEY ("pageId") REFERENCES "Page"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Category" ADD CONSTRAINT "Category_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Post" ADD CONSTRAINT "Post_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Post" ADD CONSTRAINT "Post_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PostRevision" ADD CONSTRAINT "PostRevision_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PostRevision" ADD CONSTRAINT "PostRevision_postId_fkey" FOREIGN KEY ("postId") REFERENCES "Post"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MediaAsset" ADD CONSTRAINT "MediaAsset_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Menu" ADD CONSTRAINT "Menu_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MenuItem" ADD CONSTRAINT "MenuItem_menuId_fkey" FOREIGN KEY ("menuId") REFERENCES "Menu"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MenuItem" ADD CONSTRAINT "MenuItem_parentId_fkey" FOREIGN KEY ("parentId") REFERENCES "MenuItem"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Form" ADD CONSTRAINT "Form_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FormSubmission" ADD CONSTRAINT "FormSubmission_formId_fkey" FOREIGN KEY ("formId") REFERENCES "Form"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RedirectRule" ADD CONSTRAINT "RedirectRule_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiUsageLog" ADD CONSTRAINT "AiUsageLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeoAudit" ADD CONSTRAINT "SeoAudit_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Integration" ADD CONSTRAINT "Integration_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AutomationJob" ADD CONSTRAINT "AutomationJob_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialWorkspace" ADD CONSTRAINT "SocialWorkspace_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialPage" ADD CONSTRAINT "SocialPage_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "SocialWorkspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialConnection" ADD CONSTRAINT "SocialConnection_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialContentPlan" ADD CONSTRAINT "SocialContentPlan_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "SocialWorkspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialContentPlan" ADD CONSTRAINT "SocialContentPlan_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialContent" ADD CONSTRAINT "SocialContent_planId_fkey" FOREIGN KEY ("planId") REFERENCES "SocialContentPlan"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialContent" ADD CONSTRAINT "SocialContent_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialContentRevision" ADD CONSTRAINT "SocialContentRevision_socialContentId_fkey" FOREIGN KEY ("socialContentId") REFERENCES "SocialContent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialGroup" ADD CONSTRAINT "SocialGroup_workspaceId_fkey" FOREIGN KEY ("workspaceId") REFERENCES "SocialWorkspace"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialPublishTarget" ADD CONSTRAINT "SocialPublishTarget_socialContentId_fkey" FOREIGN KEY ("socialContentId") REFERENCES "SocialContent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialPublishTarget" ADD CONSTRAINT "SocialPublishTarget_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialPublishTarget" ADD CONSTRAINT "SocialPublishTarget_socialGroupId_fkey" FOREIGN KEY ("socialGroupId") REFERENCES "SocialGroup"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MetaOAuthSession" ADD CONSTRAINT "MetaOAuthSession_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialPostInsight" ADD CONSTRAINT "SocialPostInsight_publishTargetId_fkey" FOREIGN KEY ("publishTargetId") REFERENCES "SocialPublishTarget"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialComment" ADD CONSTRAINT "SocialComment_publishTargetId_fkey" FOREIGN KEY ("publishTargetId") REFERENCES "SocialPublishTarget"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SocialComment" ADD CONSTRAINT "SocialComment_socialPageId_fkey" FOREIGN KEY ("socialPageId") REFERENCES "SocialPage"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnalyticsEvent" ADD CONSTRAINT "AnalyticsEvent_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KeywordProject" ADD CONSTRAINT "KeywordProject_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Keyword" ADD CONSTRAINT "Keyword_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "KeywordProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KeywordCluster" ADD CONSTRAINT "KeywordCluster_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "KeywordProject"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KeywordCluster" ADD CONSTRAINT "KeywordCluster_assignedTenantId_fkey" FOREIGN KEY ("assignedTenantId") REFERENCES "Tenant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KeywordClusterMember" ADD CONSTRAINT "KeywordClusterMember_clusterId_fkey" FOREIGN KEY ("clusterId") REFERENCES "KeywordCluster"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KeywordClusterMember" ADD CONSTRAINT "KeywordClusterMember_keywordId_fkey" FOREIGN KEY ("keywordId") REFERENCES "Keyword"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubdomainPlan" ADD CONSTRAINT "SubdomainPlan_keywordProjectId_fkey" FOREIGN KEY ("keywordProjectId") REFERENCES "KeywordProject"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SubdomainPlan" ADD CONSTRAINT "SubdomainPlan_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContentPlan" ADD CONSTRAINT "ContentPlan_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContentPlan" ADD CONSTRAINT "ContentPlan_subdomainPlanId_fkey" FOREIGN KEY ("subdomainPlanId") REFERENCES "SubdomainPlan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContentPlanItem" ADD CONSTRAINT "ContentPlanItem_contentPlanId_fkey" FOREIGN KEY ("contentPlanId") REFERENCES "ContentPlan"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ContentSource" ADD CONSTRAINT "ContentSource_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SourceArticle" ADD CONSTRAINT "SourceArticle_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SourceArticle" ADD CONSTRAINT "SourceArticle_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES "ContentSource"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CrawlJob" ADD CONSTRAINT "CrawlJob_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CrawlJob" ADD CONSTRAINT "CrawlJob_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES "ContentSource"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AiContentJob" ADD CONSTRAINT "AiContentJob_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("id") ON DELETE CASCADE ON UPDATE CASCADE;

