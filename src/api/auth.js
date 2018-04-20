import request from './request';

export default {
  login(username, password) {
    return request.$http.post(
      '/login/',
      {
        username,
        password,
      },
    );
  },
  async getForgotPasswordSchema() {
    const { data } = await request.$http.options('/forgot-password/');
    return data.actions.POST;
  },
  forgotPassword(email) {
    return request.$http.post(
      '/forgot-password/',
      {
        email,
      },
    );
  },
  resetPassword(nickname, token, password) {
    return request.$http.put(
      `/reset-password/${nickname}/`,
      {
        token,
        password,
      },
    );
  },
  register(email, name, nickname, password) {
    return request.$http.post(
      '/register/',
      {
        email,
        name,
        nickname,
        password,
      },
    );
  },
  profile(nickname) {
    return request.$http.get(
      `/user-profile/${nickname}/`,
    );
  },
  myProfile() {
    return request.$http.get(
      '/my-profile/',
    );
  },
};
