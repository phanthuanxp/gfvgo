import { publishMetaGroupPost, publishMetaPagePost } from "@/server/meta/client";

export type MetaPublisherAdapter = {
  publishPagePost(pageId: string, token: string, message: string): Promise<{ id: string }>;
  publishGroupPost(groupId: string, token: string, message: string): Promise<{ id: string }>;
};

export const realMetaPublisherAdapter: MetaPublisherAdapter = {
  publishPagePost: publishMetaPagePost,
  publishGroupPost: publishMetaGroupPost,
};
