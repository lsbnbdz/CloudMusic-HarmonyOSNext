interface Profile {
  userId:number
  nickname:string
  avatarUrl:string
  backgroundUrl:string
  gender:number
}

interface Account {
  id:number
  userName:string
}

interface Data {
  account:Account
  profile:Profile
}

export interface User {
  data:Data
}

export const UserClass: User = {
  data: {
    account: {
      id: 0,
      userName: ''
    },
    profile: {
      userId: 0,
      nickname: '',
      avatarUrl: '',
      backgroundUrl: '',
      gender: 0
    }
  }
};

