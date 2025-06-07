export interface ExcerciseItemType {
  //习题的id
  id: string;
  //习题的标题
  title: string;
  //习题的发布者id
  publisher: string;
  //习题发布者名
  publisherName: string;
  //习题发布时间
  publishTime: string;
  //类型
  type: string;
}

export default ExcerciseItemType;